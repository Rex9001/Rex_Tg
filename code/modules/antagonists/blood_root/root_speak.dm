/datum/action/cooldown/root_speak
	name = "Root Speak"
	desc = "A resonance to send to all other infected."
	button_icon_state = "cult_comms"

/datum/action/cooldown/root_speak/IsAvailable(feedback = FALSE)
	if(IS_BLOOD_ROOT(owner))
		return TRUE
	qdel(src)
	return ..()

/datum/action/cooldown/root_speak/Activate()
	var/input = tgui_input_text(usr, "Message to tell your fellow infected", "Root Speak")
	if(!input || !IsAvailable(feedback = TRUE))
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")
	send_message(usr, input)

/datum/action/cooldown/root_speak/proc/send_message(mob/living/user, message)
	if(!message)
		return

	var/my_message = "<span class='[noticealien]'><b>Root Speak: <br>[Infected] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/player in GLOB.player_list)
		var/mob/reciever = player
		if(IS_BLOOD_ROOT(reciever))
			to_chat(reciever, my_message)
		else if(reciever in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(reciever, user)
			to_chat(reciever, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="root_speak")
