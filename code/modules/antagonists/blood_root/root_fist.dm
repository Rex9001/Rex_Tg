/datum/action/root_fist
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"


	var/silent = FALSE
	var/weapon_type
	var/weapon_name

/datum/action/root_fist/Remove(mob/remove_from)
	unequip_held(remove_from)
	return ..()

/// Removes weapon if it exists, returns true if we removed something
/datum/action/root_fist/proc/unequip_held(mob/user)
	var/found_weapon = FALSE
	for(var/obj/item/held in user.held_items)
		found_weapon = check_weapon(user, held) || found_weapon
	return found_weapon

/datum/action/root_fist/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.temporarilyRemoveItemFromInventory(hand_item, TRUE) //DROPDEL will delete the item
		if(!silent)
			playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
			user.visible_message(span_warning("With a sickening crunch, [user] reforms [user.p_their()] [weapon_name] into an arm!"), span_notice("We assimilate the [weapon_name] back into our body."), "<span class='italics>You hear organic matter ripping and tearing!</span>")
		user.update_held_items()
		return TRUE

/datum/action/root_fist/Activate()
	var/obj/item/held = user.get_active_held_item()
	if(held && !user.dropItemToGround(held))
		user.balloon_alert(user, "hand occupied!")
		return
	if(!istype(user))
		user.balloon_alert(user, "wrong shape!")
		return
	var/obj/item/weapon = new weapon_type(user, silent)
	if(!user.put_in_hands(weapon))
		return
	if(!silent)
		playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
	return
