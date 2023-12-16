/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement. Reviving from stasis will trigger this for free. Costs 30 chemicals."
	helptext = "This is obvious to nearby people, and can destroy standard restraints and closets."
	button_icon_state = "biodegrade"
	chemical_cost = 30 //High cost to prevent spam
	dna_cost = 2
	req_human = TRUE

/datum/action/changeling/biodegrade/on_purchase(mob/user, is_respec)
	. = ..()
	RegisterSignal(user, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA), PROC_REF(on_revive))

/datum/action/changeling/biodegrade/Remove(mob/remove_from)
	UnregisterSignal(remove_from, SIGNAL_REMOVETRAIT(TRAIT_DEATHCOMA))
	return ..()

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/restraints = check_restraints(user)
	if (restraints)
		..()
	return restraints

/datum/action/changeling/biodegrade/proc/on_revive(mob/living/carbon/human/user)
	SIGNAL_HANDLER

	var/restraints = check_restraints(user)
	return restraints

/datum/action/changeling/biodegrade/proc/check_restraints(mob/living/carbon/human/user)
	if(user.handcuffed)
		var/obj/cuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(!istype(cuffs))
			return FALSE
		user.visible_message(span_warning("[user] vomits a glob of acid on [user.p_their()] [cuffs]!"), \
			span_warning("We vomit acidic ooze onto our restraints!"))
		addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), user, cuffs), 30)
		log_combat(user, user.handcuffed, "melted handcuffs", addition = "(biodegrade)")
		..()
		return TRUE

	if(user.legcuffed)
		var/obj/legcuff = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(!istype(legcuff))
			return FALSE
		user.visible_message(span_warning("[user] vomits a glob of acid on [user.p_their()] [legcuff]!"), \
			span_warning("We vomit acidic ooze onto our restraints!"))

		addtimer(CALLBACK(src, PROC_REF(dissolve_legcuffs), user, legcuff), 30)
		log_combat(user, user.legcuffed, "melted legcuffs", addition = "(biodegrade)")
		..()
		return TRUE

	if(user.wear_suit?.breakouttime)
		var/obj/item/clothing/suit/stray = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(!istype(stray))
			return FALSE
		user.visible_message(span_warning("[user] vomits a glob of acid across the front of [user.p_their()] [stray]!"), \
			span_warning("We vomit acidic ooze onto our [user.wear_suit.name]!"))
		addtimer(CALLBACK(src, PROC_REF(dissolve_straightjacket), user, stray), 30)
		log_combat(user, user.wear_suit, "melted [user.wear_suit]", addition = "(biodegrade)")
		..()
		return TRUE

	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE
		closet.visible_message(span_warning("[closet]'s hinges suddenly begin to melt and run!"))
		to_chat(user, span_warning("We vomit acidic goop onto the interior of [closet]!"))
		addtimer(CALLBACK(src, PROC_REF(open_closet), user, closet), 70)
		log_combat(user, user.loc, "melted locker", addition = "(biodegrade)")
		..()
		return TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon))
		var/obj/structure/spider/cocoon/cocoon = user.loc
		if(!istype(cocoon))
			return FALSE
		cocoon.visible_message(span_warning("[src] shifts and starts to fall apart!"))
		to_chat(user, span_warning("We secrete acidic enzymes from our skin and begin melting our cocoon..."))
		addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, cocoon), 25) //Very short because it's just webs
		log_combat(user, user.loc, "melted cocoon", addition = "(biodegrade)")
		..()
		return TRUE

	user.balloon_alert(user, "already free!")
	return FALSE

/datum/action/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/cuffs)
	if(cuffs && user.handcuffed == cuffs)
		user.visible_message(span_warning("[cuffs] dissolve[cuffs.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(cuffs.drop_location())
		qdel(cuffs)

/datum/action/changeling/biodegrade/proc/dissolve_legcuffs(mob/living/carbon/human/user, obj/legcuff)
	if(legcuff && user.legcuffed == legcuff)
		user.visible_message(span_warning("[legcuff] dissolve[legcuff.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(legcuff.drop_location())
		qdel(legcuff)

/datum/action/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/stray)
	if(stray && user.wear_suit == stray)
		user.visible_message(span_warning("[stray] dissolves into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(stray.drop_location())
		qdel(stray)

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(closet && user.loc == closet)
		closet.visible_message(span_warning("[closet]'s door breaks and opens!"))
		new /obj/effect/decal/cleanable/greenglow(closet.drop_location())
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()
		to_chat(user, span_warning("We open the container restraining us!"))

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/cocoon)
	if(cocoon && user.loc == cocoon)
		new /obj/effect/decal/cleanable/greenglow(cocoon.drop_location())
		qdel(cocoon) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, span_warning("We dissolve the cocoon!"))
