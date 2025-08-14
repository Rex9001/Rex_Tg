/datum/antagonist/fanatic
	name = "Fanatic"
	antagpanel_category = "Other"
	pref_flag = ROLE_FANATIC
	show_name_in_check_antagonists = TRUE
	preview_outfit = /datum/outfit/tiger_fanatic
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "FOR THE HIVE!!"
	hardcore_random_bonus = TRUE
	ui_name = "AntagInfoFanatic"
	var/blessings = 0
	var/datum/triangulation/triang

/datum/antagonist/fanatic/ui_data(mob/user)
	var/list/data = list()
	data["key"] = MODE_KEY_CHANGELING
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/fanatic/on_gain()
	SEND_SOUND(owner.current, sound('sound/effects/tiger_greeting.ogg'))
	triang = new()
	triang.generate_areas()
	forge_objectives()
	. = ..()

/datum/antagonist/fanatic/forge_objectives()
	var/datum/objective/changeling_blessed/blessed = new()
	blessed.owner = owner
	objectives += blessed

	var/datum/objective/bring_changeling/ling = new()
	ling.triangulation = triang
	ling.update_explanation_text()
	objectives += ling
	. = ..()

/datum/objective/bring_changeling
	name = "Summon an angel"
	explanation_text = "Use the communion device and summon an angel onto the station!"
	martyr_compatible = TRUE
	admin_grantable = FALSE
	completed = FALSE
	var/datum/triangulation/triangulation

/datum/objective/bring_changeling/update_explanation_text()
	if(isnull(triangulation))
		return

	var/list/area/triangulation_areas = triangulation.get_areas()
	var/list/area_names = list()
	for(var/area/triangle_area as anything in triangulation_areas)
		area_names += triangle_area.get_original_area_name()

	explanation_text = "Use the communion device in [area_names[1]], [area_names[2]], and [area_names[3]] to summon an angel onto the station!"

/datum/antagonist/fanatic/proc/receive_blessing()
	blessings += 1
	if(iscarbon(owner.current))
		var/mob/living/carbon/blessed_one = owner.current
		blessed_one.add_mood_event("tiger fanatic", /datum/mood_event/changeling_enjoyer)

/datum/objective/changeling_blessed
	name = "be blessed by a changeling"
	explanation_text = "Have a changeling use their powers on you 3 times."
	martyr_compatible = TRUE
	admin_grantable = TRUE
	completed = FALSE
	var/blessings_required = 3

/datum/objective/changeling_blessed/check_completion()
	var/datum/antagonist/fanatic/fanatic = owner.has_antag_datum(/datum/antagonist/fanatic)
	if(isnull(fanatic))
		return FALSE
	if(fanatic.blessings >= blessings_required)
		return TRUE
	return FALSE
