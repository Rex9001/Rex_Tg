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
	. = ..()
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
	ammo_type = /obj/item/ammo_casing/root_barb
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 15
	sharpness = SHARP_EDGED

/obj/item/gun/magic/root_fist/attack(mob/living/target_mob, mob/living/user, params)

/obj/item/ammo_casing/root_barb
	projectile_type = /obj/projectile/root_barb

/obj/projectile/root_barb
	name = "Blood Root Barb"
	icon_state = "ice_2"
	damage = 10
	damage_type = BRUTE
	armor_flag = BIO
	embedding = list(
		"impact_pain_mult" = 0,
		"embedded_pain_multiplier" = 15,
		"embed_chance" = 100,
		"embedded_fall_chance" = 0,
		"embedded_ignore_throwspeed_threshold" = TRUE,
	)

/obj/projectile/root_barb/embedded(atom/target)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/guy = target
	var/datum/disease/blood_root/virus
	// If the virus isnt in the list we create a new virus
	if(!is_type_in_list(virus , guy.get_static_viruses()))
		virus = new /datum/disease/blood_root()
		virus.infect(guy)
	virus.infection_amount += 30 SECONDS
	// Basically this only revives people if their virus stage is 1
	if(!(guy.stat == DEAD) || virus.stage >= 2)
		return
	// Heals up their damage and revives them
	guy.adjustBruteLoss(-100)
	guy.adjustToxLoss(-100)
	guy.adjustFireLoss(-100)
	guy.adjustOxyLoss(-100)
	guy.revive()
	// Sets their stage to two, granting the antag datum
	virus.update_stage(2)
	if(!guy.key)
		return
	// If the corpse isnt controlled by anyone we add a new controller
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(check_jobban = ROLE_HERETIC, poll_time = 10 SECONDS, checked_target = guy, ignore_category = poll_ignore_define, alert_pic = guy, role_name_text = "Blood root infected")
	guy.key = chosen_one.key


/obj/projectile/root_barb/unembedded()
	visible_message(span_warning("[src] cracks and twists, changing shape!"))
	for(var/obj/tongue as anything in contents)
		tongue.forceMove(get_turf(src))

	qdel(src)
