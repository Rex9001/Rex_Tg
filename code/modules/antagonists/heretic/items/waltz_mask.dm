/*
Blood can be added to the mask.
When worn will make you appear as a copy of the person whos blood is in the mask, otherwise will make your voice appear as that of your identity.
The mask can be broken to swap positions with the person whos blood is in the mask, and this will cause your disguise to drop after 1 minute.
The heretic should look just like the person when the mask is worn. When they swap the appearance should update for both of them to be that of the other.
*/

/obj/item/clothing/mask/waltz_mask
	name = "mask of the waltz"
	desc = "A mask created by a trickster. It does not seem to hold any definable shape."
	icon_state = "mad_mask"
	inhand_icon_state = null
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH | PEPPERPROOF
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	w_class = WEIGHT_CLASS_SMALL
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	clothing_traits = list(TRAIT_VOICE_MATCHES_ID)
	///Who is wearing this
	var/mob/living/carbon/human/local_user
	///Who are we impersonating
	var/mob/living/carbon/human/current_target
	///List of all blood in the mask
	var/list/victim_blood

/obj/item/clothing/mask/waltz_mask/Destroy()
	local_user = null
	return ..()

/obj/item/clothing/mask/waltz_mask/Initialize(mapload)
	. = ..()
	attach_clothing_traits(TRAIT_VOICE_MATCHES_ID)

// Inserts blood into the mask
/obj/item/clothing/mask/waltz_mask/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(victim_blood)
		user.balloon_alert(user, "already has blood!")
		return ITEM_INTERACT_BLOCKING

	var/blood_samples = list()
	for(var/blood in GET_ATOM_BLOOD_DNA(tool))
		blood_samples[blood] = 1
	for(var/datum/reagent/blood/usable_reagent as anything in tool.reagents?.reagent_list)
		if(!istype(usable_reagent, /datum/reagent/blood))
			continue
		blood_samples += usable_reagent.data["blood_DNA"]
	if(isnull(blood_samples))
		user.balloon_alert(user, "no blood!")
		attach_clothing_traits(TRAIT_VOICE_MATCHES_ID)
		return ITEM_INTERACT_BLOCKING

	victim_blood = blood_samples

/obj/item/clothing/mask/waltz_mask/attack_self(mob/user)
	if(!victim_blood)
		user.balloon_alert(user, "no blood!")
		return FALSE

	// Potential targets is an assoc list of [names] to [human mob ref].
	var/list/potential_targets = list()

	for(var/datum/mind/crewmember as anything in get_crewmember_minds())
		var/mob/living/carbon/human/human_to_check = crewmember.current
		if(!istype(human_to_check)|| !human_to_check.dna || human_to_check == user)
			continue
		var/their_blood = human_to_check.dna.unique_enzymes
		if(!victim_blood[their_blood])
			continue
		potential_targets["[human_to_check.real_name]"] = human_to_check

	var/chosen_mob = tgui_input_list(user, "Select the victim you wish to impersonate.", name, sort_list(potential_targets, GLOBAL_PROC_REF(cmp_text_asc)))
	if(isnull(chosen_mob))
		return FALSE

	var/mob/living/carbon/human/current_target = potential_targets[chosen_mob]
	if(QDELETED(current_target))
		loc.balloon_alert(user, "failed, invalid choice!")
		return FALSE

	detach_clothing_traits(TRAIT_VOICE_MATCHES_ID)
