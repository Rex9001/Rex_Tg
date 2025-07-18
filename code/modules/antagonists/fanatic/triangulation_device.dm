/obj/item/triangulation_device
	name = "Triangulation Device"
	desc = "A simple triangulation device branded by the tiger cooperative. It has a large spike"
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "weakpoint_locator"
	inhand_icon_state = "weakpoint_locator"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	/// A triangulation datum, it HAS to be assigned otherwise this will not work
	var/datum/triangulation/triangulation

/obj/item/triangulation_device/examine(mob/user)
	. = ..()
	if(!IS_FANATIC(user))
		return

	. = "A holy ritual implement used for spiritual communion and contacting angels. It requires the letting of ones own blood. Once the communion has begun the AI will be notified."

/obj/item/triangulation_device/attack_self(mob/living/user, modifiers)
	. = ..()

	try_triangulation(user)

/// Checks if we can triangulate here
/obj/item/triangulation_device/proc/try_triangulation(mob/living/user)
	if(!IS_FANATIC(user))
		to_chat(user, span_warning("You aren't interested in damaging your hand to operate this thing!"))
		return

	//No TK cheese
	if(!istype(user) || loc != user || !user.mind)
		return

	var/area/user_area = get_area(user)
	to_chat(user, "[triangulation.get_areas()]")
	if(!(user_area.type in triangulation.get_areas()))
		balloon_alert(user, "invalid area!")
		to_chat(user, span_notice("hmm, must not be a holy enough area."))
		playsound(user, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return

	user.visible_message(span_danger("[user] plunges their hand onto [src] and it starts ominously beeping!"), span_notice("You activate [src] and begin the communion. Do not exit [get_area_name(user, TRUE)] the angels are contacted!"))
	playsound(user, 'sound/items/weapons/pierce_slow.ogg', 30, TRUE)
	playsound(user, 'sound/machines/beep/triple_beep.ogg', 30, TRUE)
	// Add in their arm getting hurt and bleeding
	var/alertstr = span_userdanger("Network Alert: Station network probing attempt detected[user_area?" in [get_area_name(user, TRUE)]":". Unable to pinpoint location"].")
	for(var/mob/living/silicon/ai/ai_player in GLOB.player_list)
		to_chat(ai_player, alertstr)

	if(!do_after(user, 20 SECONDS, src, IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE | IGNORE_HELD_ITEM | IGNORE_INCAPACITATED | IGNORE_SLOWDOWNS, hidden = TRUE))
		playsound(user, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return

	triangulation.triangulation_areas -= user_area

	if(triangulation.get_areas())
		return

	// Handle spawning the changeling in a different proc that should be called here


