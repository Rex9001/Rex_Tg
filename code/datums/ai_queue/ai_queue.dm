// RELATED TO ai_server.dm
/datum/ai_queue
	/// The command que itself
	var/list/commands = list()
	/// A list containing all linked servers
	var/list/linked_servers = list()
	/// RAM: The how long the command que can be
	var/ram = 5
	/// Processing power: How quickly a command can be executed
	var/processing_power = 5
	/// The linked AI
	var/mob/living/silicon/ai/linked_ai
	/// If we are currently processing
	var/is_processing = FALSE
	/// If we are paused
	var/is_paused = FALSE
	/// Commands unlocked by components
	var/list/unlocked_commands = list(/datum/ai_command/sesame)
	// Special modifiers should also be stored somewhere, like ones changing the queue or giving the ai abilities

	/* TODO
	* Convert onclicks to commands
	* Components that add commands to the ai
	* Components that change queue processing
	* Protocol component that takes a copy of the queue and is able to execute the same queue at a later time as an ability
	* Move all malf abilities to the command system
	* Make malf APCs act as servers which the AI is able to install components into
	*/

	/* Maybe list
	* Maybe "subroutines" that take processing to uphold but have some continual effect, like auto-opening doors for someone
	*/
/datum/ai_queue/New(ai)
	. = ..()
	linked_ai = ai
	var/datum/action/innate/view_ai_queue/action = new /datum/action/innate/view_ai_queue(linked_ai.ais_queue)
	action.Grant(linked_ai)

/datum/ai_queue/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/datum/ai_queue/proc/add_linked_server(obj/machinery/ai_server/server)
	if(server in linked_servers)
		return linked_servers

	linked_servers += server
	update_components()
	return linked_servers

/datum/ai_queue/proc/remove_linked_server(obj/machinery/ai_server/server)
	if(!(server in linked_servers))
		return linked_servers

	linked_servers -= server
	update_components()
	return linked_servers

/datum/ai_queue/proc/update_components()
	var/potential_ram = 0
	var/potential_processing_power = 0
	for(var/obj/machinery/ai_server/server in linked_servers)
		for(var/obj/item/stock_parts/component/part in server.components)
			// Should account for tiers, but that can be added later
			if(istype(part, /obj/item/stock_parts/component/cpu))
				potential_processing_power += 1
			if(istype(part, /obj/item/stock_parts/component/ram))
				potential_ram += 1

	if(potential_processing_power != processing_power)
		processing_power = potential_processing_power

	if(potential_ram != ram)
		ram = potential_ram

/datum/ai_queue/proc/add_command(datum/ai_command/command)
	if(commands.len)
		var/datum/ai_command/first_command = commands[1]

		if(first_command == command)
			qdel(command)
			return

		if(commands.len >= ram)
			qdel(command)
			return

	commands += command

	if(is_paused)
		return

	// We do this bottom bit only if the command we just added is the first command
	if(command != commands[1])
		return

	// If we dont do this there is a small delay between commands we should just execute immediatly which feels odd for the player
	command.progress(processing_power)

	if(!command)
		commands -= command
		return

	if(!is_processing)
		start()

/datum/ai_queue/proc/toggle_pause()
	if(!is_paused)
		to_chat(linked_ai, span_notice("Queue paused."))
		stop()
	else
		to_chat(linked_ai, span_notice("Queue started."))
		start()
	is_paused = !is_paused

/datum/ai_queue/proc/start()
	START_PROCESSING(SSfastprocess, src)
	is_processing = TRUE

/datum/ai_queue/proc/stop()
	STOP_PROCESSING(SSfastprocess, src)
	is_processing = FALSE

/datum/ai_queue/process(seconds_per_tick)
	// Nothing to do, so do nothing
	if(!commands.len)
		stop()
		return

	var/datum/ai_command/first_command = commands[1]

	first_command.progress(processing_power * seconds_per_tick)

	if(!first_command.live)
		commands -= first_command
		return
