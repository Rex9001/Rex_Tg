/obj/machinery/ai_server
	name = "AI server"
	desc = "A server which houses and supports the AI's network."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	base_icon_state = "RD-server"
	circuit = /obj/item/circuitboard/machine/ai_server
	// The current queue this server is linked to
	var/datum/ai_queue/linked_queue
	// The parts currently inside the server
	var/list/components = list()
	// The maximum amount of components an ai server can have
	var/max_slots = 5

/obj/machinery/ai_server/Destroy(force)
	. = ..()
	linked_queue.remove_linked_server(src)
	return

/obj/machinery/ai_server/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stock_parts/component))
		return NONE

	if(!panel_open)
		return ITEM_INTERACT_BLOCKING

	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] is stuck in hand!"))
		return ITEM_INTERACT_BLOCKING

	var/dif = max_slots - length(components)

	if(!dif)
		to_chat(user, span_warning("[src] is already full!"))
		return

	LAZYADD(components, tool)
	balloon_alert(user, "added component")
	to_chat(user, span_notice("[tool] has been added to [src]. [dif] amount of components can still be added to [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ai_server/multitool_act(mob/living/user, obj/item/multitool/multi)
	if(panel_open)
		multi.set_buffer(src)
		balloon_alert(user, "saved to multitool buffer")
		to_chat(user, span_notice("You save the data in [multi] buffer. It can now be saved to servers with closed panels."))
		return ITEM_INTERACT_SUCCESS

	if(istype(multi.buffer, /obj/machinery/ai_server))
		if(multi.buffer == src)
			balloon_alert(user, "cannot link to self!")
			return ITEM_INTERACT_BLOCKING
		var/obj/machinery/ai_server/linking = multi.buffer
		if(linked_queue == linking.linked_queue)
			balloon_alert(user, "already linked to this network!")
			return ITEM_INTERACT_BLOCKING
		linked_queue.remove_linked_server(src)
		linked_queue = linking.linked_queue
		linked_queue.add_linked_server(src)
		balloon_alert(user, "data uploaded from buffer")
		return ITEM_INTERACT_SUCCESS

	balloon_alert(user, "no server data found!")
	return NONE

/obj/machinery/ai_server/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, tool)

/obj/machinery/ai_server/crowbar_act(mob/living/user, obj/item/tool)
	if(!components)
		return default_deconstruction_crowbar(user, tool)

	var/choice = tgui_input_list(user, "Select a component to remove", "Components", components)
	if(isnull(choice) || QDELETED(src) || QDELETED(user))
		return FALSE

	components -= choice
	try_put_in_hand(choice, user)

// /roundstart denotes the ai_servers spawned at roundstart
// The ones you map in, auto linked to the AI at roundstart
/obj/machinery/ai_server/roundstart/Initialize(mapload)
	. = ..()
	var/mob/living/silicon/ai/ai_player
	if(!(ai_player in GLOB.player_list))
		return

	linked_queue = ai_player.ais_queue
	linked_queue.add_linked_server(src)
