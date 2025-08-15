/obj/item/triangulation_device
	name = "Triangulation Beacon"
	desc = "A simple triangulation beacon branded by the tiger cooperative. It looks like the antenna would pierce the hand. For some reason."
	icon = 'icons/obj/antags/fanatic_beacon.dmi'
	icon_state = "Fanatic_beacon"
	inhand_icon_state = "tile"
	lefthand_file = 'icons/mob/inhands/items/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/tiles_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	/// A triangulation datum, it HAS to be assigned otherwise this will not work
	var/datum/triangulation/triangulation
	/// Blessed, if this device has had a blessing sticker applied to it
	var/blessed = FALSE
	/// Activated, if this triangulation beacon has been activated. If it has it cannot be used again (unless primed)
	var/activated = FALSE
	/// Primed, if we are done with our triangulations
	var/primed = FALSE
	/// If we are currently using this
	var/in_use = FALSE

/* TODO:
* Add the changeling spawning
* Make purity seals/blessing seals that you have to put on the beacon to use them (You get a message like "This is not blessed.")
*/

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
	if(in_use)
		return

	if(!IS_FANATIC(user))
		to_chat(user, span_warning("You aren't interested in damaging your hand to operate this thing!"))
		return

	//No TK cheese
	if(!istype(user) || loc != user || !user.mind)
		return

	if(primed)
		try_spawn_ling(user)
		return

	if(activated)
		return

	if(!blessed)
		to_chat(user, span_warning("This device has not been properly blessed for communion!"))
		return

	var/area/user_area = get_area(user)
	if(!(user_area in triangulation.get_areas()))
		balloon_alert(user, "invalid area!")
		to_chat(user, span_notice("Hmm, must not be a holy enough area."))
		playsound(user, 'sound/machines/buzz/buzz-sigh.ogg', 30, TRUE)
		return

	user.visible_message(span_danger("[user] presses down on [src] and an antenna pierces straight through their arm! [src] starts ominously beeping!"), span_notice("You press your hand onto [src] and an antenna pierces your hand to begin the communion. Do not exit [get_area_name(user, TRUE)] until the angels are contacted!"))
	playsound(user, 'sound/items/weapons/pierce_slow.ogg', 30, TRUE)
	playsound(user, 'sound/machines/beep/triple_beep.ogg', 30, TRUE)
	var/obj/item/bodypart/arm/arm = user.get_active_hand(src)

	if(arm)
		arm.adjustBleedStacks(5)

	var/alertstr = span_userdanger("Network Alert: Station network probing attempt detected[user_area?" in [get_area_name(user, TRUE)]":". Unable to pinpoint location"].")
	for(var/mob/living/silicon/ai/ai_player in GLOB.player_list)
		to_chat(ai_player, alertstr)

	in_use = TRUE
	icon_state = "Fanatic_beacon_activating"
	interaction_flags_item = NONE
	forceMove(get_turf(user))
	addtimer(CALLBACK(src, PROC_REF(activate), user), 20 SECONDS)

/obj/item/triangulation_device/proc/activate(user)
	var/area/user_area = get_area(user)
	in_use = FALSE
	activated = TRUE
	icon_state = "Fanatic_beacon_activated"

	triangulation.triangulation_areas -= user_area
	to_chat(user, span_notice("The time has passed. Communion successful."))
	say("Communion successful. Praise be to the angels!")
	playsound(src, 'sound/effects/pray_chaplain.ogg', 10, TRUE)

	if(triangulation.get_areas())
		return

	try_spawn_ling(user)

/obj/item/triangulation_device/proc/try_spawn_ling(mob/living/user)
	// if this fails, set primed to true so they can try again later
	primed = TRUE
	return
