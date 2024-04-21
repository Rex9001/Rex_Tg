/**********************For Sandstation, the dune tiles**************************/

/turf/open/misc/sandplanet
	icon = 'icons/turf/mining.dmi'
	gender = PLURAL
	name = "dune"
	icon_state = "dune"
	base_icon_state = "dune"
	desc = "Course sands forming a dune, it can be dug up for sand."
	initial_gas_mix = SANDPLANET_DEFAULT_ATMOS
	planetary_atmos = TRUE

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	var/smooth_icon = 'icons/turf/floors/ash.dmi'

/turf/open/misc/sandplanet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diggable, /obj/item/stack/ore/glass/basalt, 2)
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)
