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
	/// The amount of infection this person has
	var/infection_amount = 0
	/// The amount of infection this person has to have in order to gain the antag datum and move up a stage
	var/static/infection_goal = 0

/datum/disease/beesease/infect(mob/living/infectee, make_copy = TRUE)
	. = ..()
	GLOB.blood_root_infected += infectee
	if(!infection_goal)
		var/initial_infection_goal = 100
		if(HAS_TRAIT(infectee, TRAIT_MINDSHIELD))
			initial_infection_goal = 200

		// After 10 infected people this time doubles
		infection_goal = initial_infection_goal * length(GLOB.blood_root_infected)/5


/datum/disease/beesease/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			infection_amount += 1
			if(infection_amount >= infection_goal)
				update_stage(min(stage + 1, max_stages))
		if(2)

		if(3)

		if(4)

	return
