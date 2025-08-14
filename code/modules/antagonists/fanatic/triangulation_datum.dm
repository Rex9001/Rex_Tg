// Triangulation, its a datum given to the fanatic which is then passed to the triangulation devices and it handles
// creation and storage of areas we triangulate in
/datum/triangulation
	/// The areas that triangulation have to be performed in
	var/list/area/triangulation_areas = list()
	/// The amount of areas we have to triangulate in, used to generate the areas
	var/initial_triangulation_amount = 3

/// Generates the areas we should triangulate in
/datum/triangulation/proc/generate_areas()
	/// List of high-security areas that we pick required ones from
	var/list/allowed_areas = typecacheof(list(/area/station/command,
		/area/station/comms,
		/area/station/engineering,
		/area/station/science,
		/area/station/security,
	))

	var/list/blacklisted_areas = typecacheof(list(/area/station/engineering/hallway,
		/area/station/engineering/lobby,
		/area/station/engineering/storage,
		/area/station/science/lobby,
		/area/station/science/ordnance/bomb,
		/area/station/security/prison,
	))

	var/list/possible_areas = GLOB.areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(!is_type_in_typecache(possible_area, allowed_areas) || initial(possible_area.outdoors) || is_type_in_typecache(possible_area, blacklisted_areas))
			possible_areas -= possible_area

	for(var/i in 1 to initial_triangulation_amount)
		triangulation_areas += pick_n_take(possible_areas)

	return triangulation_areas

/// Returns the triangulation areas, returns FALSE if we have no triangulation_areas
/datum/triangulation/proc/get_areas()
	if(!triangulation_areas.len)
		return FALSE
	return triangulation_areas
