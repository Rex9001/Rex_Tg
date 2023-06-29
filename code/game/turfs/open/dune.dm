/**********************For Sandstation, the dune tiles**************************/

/turf/open/misc/sandplanet
	icon = 'icons/turf/mining.dmi'
	gender = PLURAL
	name = "dune"
	icon_state = "dune"
	base_icon_state = "dune"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	desc = "Course sands forming a dune, it can be dug up for sand."
	baseturfs = /turf/open/misc/ashplanet/wateryrock //I assume this will be a chasm eventually, once this becomes an actual surface
	initial_gas_mix = SANDPLANET_DEFAULT_ATMOS
	planetary_atmos = TRUE

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	var/smooth_icon = 'icons/turf/floors/ash.dmi'

/turf/open/misc/sandplanet/
