/// A command the AI uses to interact with pretty much all machinery UI in the game
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
	// src. to make it clearer if we're referring to our own variables
	src.target = target
	src.user = user
	src.action = action
	src.params = params.Copy()
	src.ui = ui
	src.state = state
	name = "[target] [action]"

/datum/ai_command/ui_act/Destroy()
	target = null
	user = null
	ui = null
	state = null
	return ..()

/datum/ai_command/ui_act/execute()
	if(target && user)
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
	return ..()
