/*
### Bottled Storm
- 1 Glass Bottle
- 4 Power Cells OR 1 Mega Cell

Captured lightning in a bottle. When thrown or broken will repulse all nearby targets and shock them for a small amount of burn damage.

### Fragment of False Darkness
- 1 Glass Shard
- 1 Shattered Lightbulb
- 1 Knife (Not consumed)

Must be performed in darkness. Can be broken in hand to let out a blinding gas.
*/
/obj/item/fragment_of_dark
	name = "fragment of false darkness"
	desc = "A shard of swirling dark fog. Something about it feels false."
	icon = 'icons/obj/debris.dmi'
	icon_state = "large"
	icon_angle = -45
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	inhand_icon_state = "shard-glass"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	custom_materials = list(/datum/material/glass=SHEET_MATERIAL_AMOUNT)
	attack_verb_continuous = list("stabs", "slashes", "slices", "cuts")
	attack_verb_simple = list("stab", "slash", "slice", "cut")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/item_shard
	max_integrity = 40
	sharpness = SHARP_EDGED

/obj/item/fragment_of_dark/attack_self(mob/user)
	playsound(src, 'sound/effects/hallucinations/wail.ogg', 50, TRUE, -3)
	do_smoke(5, src, loc, smoke_type = /datum/effect_system/fluid_spread/smoke/bad/black)
	var/obj/item/shard/fragment = new(drop_location())
	qdel(src)
