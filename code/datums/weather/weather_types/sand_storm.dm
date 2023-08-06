//Sand Storms happen semi-frequently on the dunes. They heavily obscure vision, and cause high brute damage to anyone caught outside.
/datum/weather/sand_storm
	name = "sand storm"
	desc = "An intense atmospheric event during which sand is picked up by strong winds at speeds were they can flay unprotected flesh."

	telegraph_message = "<span class='boldwarning'>You feel the wind picking up speed. There is a large cloud of sand moving towards you. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Sand darts around you in a gale force wind tearing your flesh! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounce'>The sand drops away around you as you feel thew ind slow. It should be safe to go outside now.</span>"
	end_duration = 300
	end_overlay = "light_ash"

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_SANDSTORM
	immunity_type = TRAIT_SANDSTORM_IMMUNE

	probability = 100

	barometer_predictable = TRUE
	var/list/weak_sounds = list()
	var/list/strong_sounds = list()

/datum/weather/sand_storm/telegraph()
	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]
	for(var/i in 1 to eligible_areas.len)
		var/area/place = eligible_areas[i]
		if(place.outdoors)
			weak_sounds[place] = /datum/looping_sound/weak_outside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_outside_ashstorm
		else
			weak_sounds[place] = /datum/looping_sound/weak_inside_ashstorm
			strong_sounds[place] = /datum/looping_sound/active_inside_ashstorm
		CHECK_TICK

	//We modify this list instead of setting it to weak/stron sounds in order to preserve things that hold a reference to it
	//It's essentially a playlist for a bunch of components that chose what sound to loop based on the area a player is in
	GLOB.ash_storm_sounds += weak_sounds
	return ..()

/datum/weather/ash_storm/start()
	GLOB.ash_storm_sounds -= weak_sounds
	GLOB.ash_storm_sounds += strong_sounds
	return ..()

/datum/weather/ash_storm/wind_down()
	GLOB.ash_storm_sounds -= strong_sounds
	GLOB.ash_storm_sounds += weak_sounds
	return ..()

/datum/weather/ash_storm/can_weather_act(mob/living/mob_to_check)
	. = ..()
	if(!. || !ishuman(mob_to_check))
		return
	var/mob/living/carbon/human/human_to_check = mob_to_check
	if(human_to_check.get_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		return FALSE

/datum/weather/sand_storm/weather_act(mob/living/victim)
	victim.adjustBruteLoss(5)

/datum/weather/ash_storm/end()
	GLOB.ash_storm_sounds -= weak_sounds
	for(var/turf/open/misc/asteroid/basalt/basalt as anything in GLOB.dug_up_basalt)
		if(!(basalt.loc in impacted_areas) || !(basalt.z in impacted_z_levels))
			continue
		basalt.refill_dug()
	return ..()
