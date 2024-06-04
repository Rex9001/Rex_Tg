/datum/antagonist/blood_root
	name = "\improper Blood Root"
	roundend_category = "blood_root"
	antagpanel_category = "Blood Root"
	job_rank = ROLE_CHANGELING
	antag_moodlet = /datum/mood_event/focused
	antag_hud_name = "blood_root"
	hijack_speed = 0.5
	ui_name = "AntagInfoChangeling"
	suicide_cry = "THE ROOT SPREADS WITHOUT ME!!"
	can_assign_self_objectives = FALSE
	default_custom_objective = "Consume the station's most valuable genomes."
	hardcore_random_bonus = TRUE
	/// Stage, the stage the infection is on, used to grant abilities
	var/infection_stage = 1

/datum/antagonist/blood_root/proc/set_stage(stage)
	var/mob/living/our_mob = owner.current
	var/adjusted_stage = stage - 1
	if(infection_stage == adjusted_stage)
		return
	infection_stage = adjusted_stage
	apply_stage_abilities(our_mob)

/datum/antagonist/blood_root/proc/apply_stage_abilities(mob/our_mob)
	switch(infection_stage)
		if(1)
			return
		if(2)
			var/datum/action/cooldown/root_fist/fist= new /datum/action/cooldown/root_fist()
			fist.Grant(our_mob)
			// Our guy should look more fucked up
			// We want stun resistence and passive healing with the caviat of MORE burn damage here
			// Should also add a spell to grant a weapon which embeds fragments of blood root into someone
			// Spell should also be able to shoot people with barbs
			/* Barbs also have the unique effect of working on corpses.
			Corpses infected with barbs will seek a ghost to control them if not previously owned and then ressurect the corpse with Phase 1 infection.*/
		if(3)
			var/old_fist = locate(/datum/action/cooldown/root_fist) in our_mob.actions
			qdel(old_fist)
			// Same effects as stage 2 but beefed up
			// Should be able to make tiles that infect people and heal infected
			// Monsterous human subtypes, dead space esque


/datum/antagonist/blood_root/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	add_team_hud(our_mob)
	var/datum/action/cooldown/root_speak/root = new /datum/action/cooldown/root_speak()
	root.Grant(our_mob)

/datum/antagonist/lunatic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	var/root = locate(/datum/action/cooldown/root_speak) in our_mob.actions
	qdel(root)

// ENDGAME: Conglomorate everyone into a big monster
