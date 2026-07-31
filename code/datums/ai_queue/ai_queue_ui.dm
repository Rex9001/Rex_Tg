// Holds all the datums relating to the queues ui
/datum/ai_queue/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Doesnt exist yet
		ui = new(user, src, "AiQueueUi")
		ui.open()

/datum/ai_queue/ui_data(mob/user)
	var/list/data = list()

	data["ram"] = ram
	data["processing_power"] = processing_power
	data["queue_length"] = length(commands)
	data["is_paused"] = is_paused
	data["commands"] = get_commands_ui_data()
	data["unlocked"] = get_special_commands_ui_data()

	return data

/datum/ai_queue/proc/get_commands_ui_data()
	var/list/command_data = list()
	for(var/datum/ai_command/command as anything in commands)
		command_data += list(list(
			"name" = command.name,
			"processing" = command.processing,
			"process_required" = command.process_required,
		))
	return command_data

/datum/ai_queue/proc/get_special_commands_ui_data()
	var/list/spec_data = list()
	for(var/datum/ai_command/path as anything in unlocked_commands)
		spec_data += list(list(
			"name" = initial(path.name),
			"process_required" = initial(path.process_required),
		))
	return spec_data

/datum/ai_queue/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/ai_queue/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_pause")
			toggle_pause()
			return TRUE
		if("add_to_queue")
			var/command_name = params["command"]
			var/datum/ai_command/nu_command
			switch(command_name)
				if("Large Scale Door Opening")
					var/mob/eye/camera/ai/peeper = linked_ai.eyeobj
					nu_command = new /datum/ai_command/sesame(peeper.loc, linked_ai)
			add_command(nu_command)
			return TRUE

/// Lets the AI pull up the queue, should be moved to a static ui button eventually
/datum/action/innate/view_ai_queue
	name = "View Command Queue"
	desc = "View and manage your queue."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "modules_menu"
	/// The queue datum this action opens
	var/datum/ai_queue/linked_queue

/datum/action/innate/view_ai_queue/Activate()
	if(!linked_queue)
		var/mob/living/silicon/ai/linkee = owner
		linked_queue = linkee.ais_queue
	linked_queue.ui_interact(owner)
