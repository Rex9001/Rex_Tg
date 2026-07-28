// RELATED TO ai_server.dm
/datum/ai_queue
	/// The command que itself
	// Not sure how I will do this
	// Current idea is to datumize the ais actions like that
	var/list/commands = list()
	/// A list containing all linked servers
	// For malf ais hacked APCs will also act as linked servers
	var/list/linked_servers = list()
	// These are 1 for now, until servers are fixed
	/// RAM: The how long the command que can be
	var/ram = 5
	/// Processing power: How quickly a command can be executed
	var/processing_power = 5
	/// The linked AI
	var/mob/living/silicon/ai/linked_ai
	/// If we are currently processing
	var/is_processing = FALSE
	// Special modifiers should also be stored somewhere, like ones changing the queue or giving the ai abilities

	/* TODO
	* Being able to pause the queue
		* This requires a button for it
	* Components for the servers, more than just placeholders
	* Components that add abilities to the ai
	* Components that change queue processing
	* Protocol component that takes a copy of the queue and is able to execute the same queue at a later time as an ability
	* Move all malf abilities to the command system
	* Make malf APCs act as servers which the AI is able to install components into
	*/

/datum/ai_queue/New(ai)
	. = ..()
	linked_ai = ai

/datum/ai_queue/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/datum/ai_queue/proc/change_linked_servers(obj/machinery/ai_server/server)
	if(server in linked_servers)
		linked_servers -= server
	else
		linked_servers += server

	update_components()
	return linked_servers

/datum/ai_queue/proc/update_components()
	var/potential_ram = 0
	var/potential_processing_power = 0
	for(var/obj/machinery/ai_server/server in linked_servers)
		for(var/obj/item/stock_parts/part in server.component_parts)
			// Should account for tiers, but that can be added later
			if(istype(part, /obj/item/stock_parts/cpu))
				potential_processing_power += 1
			if(istype(part, /obj/item/stock_parts/ram))
				potential_ram += 1

	if(potential_processing_power != processing_power || potential_ram != ram)
		processing_power = potential_processing_power
		ram = potential_ram

/datum/ai_queue/proc/add_command(datum/ai_command/command)
	if(!is_processing)
		is_processing = TRUE
		START_PROCESSING(SSfastprocess, src)

	if(commands.len)
		var/datum/ai_command/first_command = commands[1]

		if(first_command == command)
			qdel(command)
			return

		if(commands.len >= ram)
			qdel(command)
			return

	commands += command

/datum/ai_queue/process(seconds_per_tick)
	// Nothing to do, so do nothing
	if(!commands.len)
		STOP_PROCESSING(SSfastprocess, src)
		is_processing = FALSE
		return

	var/datum/ai_command/first_command = commands[1]

	if(!first_command.live)
		commands -= first_command
		return

	first_command.progress(processing_power * seconds_per_tick)
