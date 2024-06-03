/datum/action/spell/root_fist
	name = "Blood Root Barbs"
	desc = "Covers your arms in barbs of infectious matter. High embed chance on hit. If embeded increases infection in target and if embeded in corpses revives them as t1 infected."
	button_icon =
	button_icon_state = "alien_hide"
	background_icon =

	var/silent = FALSE
	var/weapon_type

/datum/action/spell/root_fist/Remove()
	unequip_held(owner)
	return ..()

/// Removes weapon if it exists, returns true if we removed something
/datum/action/spell/root_fist/proc/unequip_held(mob/user)
	var/found_weapon = FALSE
	for(var/obj/item/held in user.held_items)
		found_weapon = check_weapon(user, held) || found_weapon
	return found_weapon

/datum/action/spell/root_fist/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.temporarilyRemoveItemFromInventory(hand_item, TRUE) //DROPDEL will delete the item
		if(!silent)
			playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
			user.visible_message(span_warning("[user]s arms barbs retract with a sound of splitting bone!"), span_notice("We redraw the barbs from our arm."), "<span class='italics>You hear organic matter ripping and tearing!</span>")
		user.update_held_items()
		return TRUE

/datum/action/spell/root_fist/Activate()
	var/obj/item/held = owner.get_active_held_item()
	if(held && !owner.dropItemToGround(held))
		owner.balloon_alert(owner, "hand occupied!")
		return
	if(unequip_held(owner))
		return
	if(!istype(owner))
		owner.balloon_alert(owner, "wrong shape!")
		return
	var/obj/item/weapon = new weapon_type(owner, silent)
	if(!owner.put_in_hands(weapon))
		return
	if(!silent)
		playsound(owner, 'sound/effects/blobattack.ogg', 30, TRUE)
	return

/obj/item/gun/magic/root_fist
	name = "Barbed arm"
	desc = "A deadly combination of laziness and bloodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 15
	sharpness = SHARP_EDGED

