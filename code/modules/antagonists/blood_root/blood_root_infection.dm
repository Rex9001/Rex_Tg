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
	var/static/infection_goal = 0

/datum/disease/blood_root/infect(mob/living/infectee, make_copy = TRUE)
	. = ..()
	if(!infection_goal)
		var/initial_infection_goal = 80 SECONDS
		if(HAS_TRAIT(infectee, TRAIT_MINDSHIELD))
			initial_infection_goal = 160 SECONDS
		infection_goal = initial_infection_goal

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
	return

/datum/disease/blood_root/spread(force_spread = 0)
	. = ..()
	var/list/datum/disease/diseases = guy_to_infect.get_static_viruses()
	if(!var/datum/disease/blood_root/virus in diseases)
		return
	virus.increase_infection()

/datum/disease/blood_root/proc/increase_infection()
	if(infection_amount > 1200 SECONDS)
		return
	// The infection amount depends on the amount of blood root stage 2 infected we have
	infection_amount += 1 / ((length(GLOB.blood_root_infected)+2) / 5)
