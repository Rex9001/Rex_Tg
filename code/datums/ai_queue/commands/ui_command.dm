	/*
	* This may prove difficult to code here is the idea:
	* The AI clicks something
	* This opens the UI menu for that thing (machinery)
	* The AI clicks something on the UI
	* This command intercepts the click and places it in the queue
	* After this command processes the clicked action will occur
	* WORST CASE this might require a refactor of UI_ACT for all types of machinery
	*/

/datum/ai_command/ui_act
	name = "AI UI Interaction"
	process_required = 1

	/// The machine (or other movable) whose UI is being acted on
	var/atom/movable/target
	/// The AI performing the interaction
	var/mob/living/silicon/ai/user
	/// The tgui action string that was clicked
	var/action
	/// The tgui params payload
	var/list/params
	/// The open tgui window, so the real call can push fresh data back to it
	var/datum/tgui/ui
	/// ui_state used to validate the interaction when it actually fires
	var/datum/ui_state/state

/datum/ai_command/ui_act/New(atom/movable/target, mob/living/silicon/ai/user, action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	to_chat(user, span_warning("Added to queue"))
	// src. to make it clearer if we're referring to our own variables
	src.target = target
	src.user = user
	src.action = action
	src.params = params.Copy()
	src.ui = ui
	src.state = state
	name = "[target] [action]"
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_involved_qdel))
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_involved_qdel))

/datum/ai_command/ui_act/Destroy()
	if(target)
		UnregisterSignal(target, COMSIG_QDELETING)
	if(user)
		UnregisterSignal(user, COMSIG_QDELETING)
	target = null
	user = null
	ui = null
	state = null
	return ..()

/datum/ai_command/ui_act/proc/on_involved_qdel(datum/source)
	SIGNAL_HANDLER
	live = FALSE
	qdel(src)

/datum/ai_command/ui_act/execute()
	if(live && target && user)
		if(target.ui_status(user, state) <= UI_CLOSE)
			to_chat(user, span_warning("Connection lost before the command could process."))
		else
			params["ai_processed"] = TRUE
			var/mob/old_usr = usr
			usr = user
			var/handled = target.ui_act(action, params, ui, state)
			usr = old_usr
			if(handled)
				SStgui.update_uis(target)
	to_chat(user, span_warning("Command executed."))
	return ..()
