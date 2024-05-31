GLOBAL_LIST_EMPTY(blood_root_infected)

// The diesease that blood rot antags have
/datum/disease/blood_root
	disease_flags = CAN_CARRY
	max_stages = 4
	stage_prob = 0
	spread_text = "Airborne"
	cure_text = "Drain of blood"
	cures = NONE
	agent = "Blood Root"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/simple_animal, /mob/living/basic)
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD
	bypasses_immunity = TRUE
	severity = NONE
	spread_flags = DISEASE_SPREAD_AIRBORNE | DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_CONTACT_SKIN
	/// The amount of infection this person has
	var/infection_amount = 0
	/// The amount of infection this person has to have in order to gain the antag datum and move up a stage
	var/infection_goal = 80 SECONDS

/datum/disease/blood_root/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(affected_mob.blood_volume < BLOOD_VOLUME_BAD)
		GLOB.blood_root_infected -= affected_mob
		cure()
		return FALSE

	switch(stage)
		if(1)
			if(infection_amount >= infection_goal)
				GLOB.blood_root_infected += affected_mob
				update_stage(min(stage + 1, max_stages))
				affected_mob.mind.add_antag_datum(/datum/antagonist/blood_root)
		if(2)
			if(infection_amount >= 600 SECONDS)
				update_stage(min(stage + 1, max_stages))
			increase_infection()
			spread()
		if(3)
			if(infection_amount >= 1200 SECONDS)
				update_stage(min(stage + 1, max_stages))
			increase_infection()
			spread()
		if(4)
			spread()

	var/datum/antagonist/blood_root/antag = IS_BLOOD_ROOT(affected_mob)
	if(!antag)
		return
	antag.set_stage(stage)
	return

// Sadly have to slot in the whole proc because we want to do something special in the last loop
/datum/disease/blood_root/spread(force_spread = 0)
	if(!affected_mob)
		return

	if(!(spread_flags & DISEASE_SPREAD_AIRBORNE) && !force_spread)
		return

	if(affected_mob.internal) //if you keep your internals on, no airborne spread at least
		return

	if(HAS_TRAIT(affected_mob, TRAIT_NOBREATH)) //also if you don't breathe
		return

	if(!has_required_infectious_organ(affected_mob, ORGAN_SLOT_LUNGS)) //also if you lack lungs
		return

	if(!affected_mob.CanSpreadAirborneDisease()) //should probably check this huh
		return

	if(HAS_TRAIT(affected_mob, TRAIT_VIRUS_RESISTANCE) || (affected_mob.satiety > 0 && prob(affected_mob.satiety/2))) //being full or on spaceacillin makes you less likely to spread a virus
		return

	var/spread_range = 2

	if(force_spread)
		spread_range = force_spread

	var/turf/T = affected_mob.loc
	if(istype(T))
		for(var/mob/living/carbon/guy_to_infect in oview(spread_range, affected_mob))
			var/turf/V = get_turf(guy_to_infect)
			if(disease_air_spread_walk(T, V))
				infect(guy_to_infect)
			var/datum/disease/blood_root/virus
			if(!(virus in diseases))
				return
			virus.increase_infection()

/datum/disease/blood_root/proc/increase_infection()
	if(infection_amount >= 1200 SECONDS)
		return
	if(HAS_TRAIT(affected_mob, TRAIT_MINDSHIELD))
		// Half as much infection if they are mindshielded
		infection_amount += (1 / ((length(GLOB.blood_root_infected)+2) / 5)) / 2
		return
	// The infection amount depends on the amount of blood root stage 2 infected we have
	infection_amount += 1 / ((length(GLOB.blood_root_infected)+2) / 5)

/datum/disease/blood_root/cure()
	var/datum/antagonist/blood_root/antag = IS_BLOOD_ROOT(affected_mob)
	if(antag)
		affected_mob.mind.remove_antag_datum(antag)
	return ..()

/datum/disease/blood_root/try_infect(mob/living/infectee, make_copy = TRUE)
	// No conversion antag chikanery and changelings should be virus immune
	if(IS_CHANGELING(infectee) || IS_CULTIST_OR_CULTIST_MOB(infectee) || IS_REVOLUTIONARY(infectee))
		return FALSE

	return ..()
