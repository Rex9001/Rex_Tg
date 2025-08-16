// A sticker tiger cooperative fanatics get that can be used to bless triangulation devices
/obj/item/sticker/fanatic
	name = "Blessed Seal"
	desc = "A sticker with a tiger cooperative symbol on it. It has a tag stating it is 100% sanctified."

	icon_state = "fanatic_blessing"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	exclude_from_random = TRUE

	/// The chant we say throughout sticking this onto something
	var/list/chant = list(
		"The will of the angels be done.",
		"Lay meat and bone at the angels's feet.",
		"As the seal of protection is placed upon this machine so may the litanies of protection ward its purpose.",
		"May my soul be guarded from impurity, and its purpose be filled.",
		"As the blood from my hand writes the message, may it in it's turn, guide it to the true angels."
	)
	/// The amount of time it takes to stick this onto something.
	var/sticking_time = 20 SECONDS

/obj/item/sticker/fanatic/examine(mob/user)
	. = ..()
	if(!IS_FANATIC(user))
		return

	. = "A holy, sanctified and blessed seal of protection. It must be placed on a beacon in order for the communion to be possible however it can also be used to bless other objects."

/obj/item/sticker/fanatic/attempt_attach(atom/target, mob/user, px, py)
	if(COUNT_TRAIT_SOURCES(target, TRAIT_STICKERED) >= 15)
		balloon_alert_to_viewers("sticker won't stick!")
		return FALSE

	if(isnull(px) || isnull(py))
		var/icon/target_mask = icon(target.icon, target.icon_state)

		if(isnull(px))
			px = rand(1, target_mask.Width())

		if(isnull(py))
			py = rand(1, target_mask.Height())

	if(!isnull(user))
		user.do_attack_animation(target, used_item = src)
		target.balloon_alert(user, "sticker sticked")
		var/mob/living/victim = target
		if(istype(victim) && !isnull(victim.client))
			user.log_message("stuck [src] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [src] stuck to them by [key_name(user)]", LOG_ATTACK)

	if(!IS_FANATIC(user))
		target.AddComponent(/datum/component/sticker, src, get_dir(target, src), px, py, null, null, examine_text)
		return TRUE

	for(var/line in chant)
		if(!length(chant)) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, sticking_time/length(chant)))
			return FALSE
		user.say(line)

	if(!do_after(user, sticking_time/length(chant))) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE

	if(!istype(target, /obj/item/triangulation_device))
		target.AddComponent(/datum/component/sticker, src, get_dir(target, src), px, py, null, null, examine_text)
		return TRUE

	var/obj/item/triangulation_device/triang_device = target
	triang_device.blessed = TRUE
	target.AddComponent(/datum/component/sticker, src, get_dir(target, src), px, py, null, null, examine_text)
	to_chat(user, span_notice("The [triang_device] has been properly blessed for communion!"))

	return TRUE


/obj/item/storage/box/stickers/fanatic
	name = "Tiger cooperative blessings pack"
	desc = "A cheaply made little box for stickers with a seal hastly slapped onto it."
	illustration = "fanatic_blessing"

/obj/item/storage/box/stickers/fanatic/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/sticker/fanatic(src)

/obj/item/storage/box/stickers/examine(mob/user)
	. = ..()
	if(!IS_FANATIC(user))
		return

	. = "A holy container thrice blessed to hold seals of protection."
