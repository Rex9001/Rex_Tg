/datum/action/cooldown/root_fist
	name = "Blood Root Barbs"
	desc = "Covers your arms in barbs of infectious matter. High embed chance on hit. If embeded increases infection in target and if embeded in corpses revives them as t1 infected."
	button_icon = NONE
	button_icon_state = "alien_hide"
	background_icon = NONE
	cooldown_time = 10 SECONDS

	var/weapon_type

/datum/action/cooldown/root_fist/Remove()
	unequip_held(owner)
	return ..()

/// Removes weapon if it exists, returns true if we removed something
/datum/action/cooldown/root_fist/proc/unequip_held(mob/user)
	var/found_weapon = FALSE
	for(var/obj/item/held in user.held_items)
		found_weapon = check_weapon(user, held) || found_weapon
	return found_weapon

/datum/action/cooldown/root_fist/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.temporarilyRemoveItemFromInventory(hand_item, TRUE) //DROPDEL will delete the item
		playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
		user.visible_message(span_warning("[user]s arms barbs retract with a sound of splitting bone!"), span_notice("We redraw the barbs from our arm."), "<span class='italics>You hear organic matter ripping and tearing!</span>")
		user.update_held_items()
		return TRUE

/datum/action/cooldown/root_fist/Activate()
	var/obj/item/held = owner.get_active_held_item()
	if(held && !owner.dropItemToGround(held))
		owner.balloon_alert(owner, "hand occupied!")
		return FALSE
	if(unequip_held(owner))
		return FALSE
	if(!istype(owner))
		owner.balloon_alert(owner, "wrong shape!")
		return FALSE
	var/obj/item/weapon = new weapon_type(owner)
	if(!owner.put_in_hands(weapon))
		return FALSE
	playsound(owner, 'sound/effects/blobattack.ogg', 30, TRUE)
	return TRUE

/obj/item/gun/magic/root_fist
	name = "Barbed arm"
	desc = "A deadly combination of laziness and bloodlust, this blade allows the user to dismember their enemies without all the hard work of actually swinging the sword."
	fire_sound = 'sound/effects/blobattack.ogg'
	ammo_type = /obj/item/ammo_casing/root_barb
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 15
	sharpness = SHARP_EDGED
	/// How many barbs we have embeded
	var/barbs_embed = 0

/obj/item/gun/magic/root_fist/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	var/obj/projectile/root_barb/shot
	if(!shot.can_embed_into(target_mob))
		return
	barbs_embed += 1
	if(!barbs_embed >= 3)
		return
	loose_barbs(user)

/obj/item/gun/magic/root_fist/fire_gun(atom/target, mob/living/user, flag, params)
	. = ..()
	loose_barbs(user)

/obj/item/gun/magic/root_fist/proc/loose_barbs(mob/living/user)
	visible_message(span_warning("[user]s [src]s runs out of barbs!"))
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	user.update_held_items()

/obj/item/ammo_casing/root_barb
	projectile_type = /obj/projectile/root_barb

/obj/projectile/root_barb
	name = "Blood Root Barb"
	icon_state = "ice_2"
	damage = 10
	damage_type = BRUTE
	armor_flag = BIO
	embedding = list(
		impact_pain_mult = 0,
		embedded_pain_multiplier = 15,
		embed_chance = 50,
		fall_chance = 0,
	)

// PLANS: MAKE THIS SHIT APPLY WHILST ITS EMBEDED AND THEN STOP WHEN THE BARB IS PULLED OUT
/obj/projectile/root_barb/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/guy = target
	var/datum/disease/blood_root/virus = HAS_BLOOD_ROOT(guy)
	// If the virus isnt in the list we create a new virus
	if(!virus)
		virus = new /datum/disease/blood_root()
		virus.infect(guy)
	virus.infection_amount += 30
	// Basically this only revives people if their virus stage is 1
	if(!(guy.stat == DEAD) || virus.stage >= 2)
		return
	// Heals up their damage 	and revives them
	guy.adjustBruteLoss(-200)
	guy.adjustToxLoss(-200)
	guy.adjustFireLoss(-200)
	guy.adjustOxyLoss(-200)
	guy.revive()
	// Sets their stage to two, granting the antag datum
	virus.update_stage(2)
	if(!guy.key)
		return
	// If the corpse isnt controlled by anyone we add a new controller
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(check_jobban = ROLE_HERETIC, poll_time = 10 SECONDS, checked_target = guy, alert_pic = guy, role_name_text = "Blood root infected")
	guy.key = chosen_one.key
