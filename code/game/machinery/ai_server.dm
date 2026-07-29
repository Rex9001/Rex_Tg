/obj/machinery/ai_server
	name = "AI server"
	desc = "A server which houses and supports the AI's network."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	base_icon_state = "RD-server"
	circuit = /obj/item/circuitboard/machine/ai_server
	/*
	Okay so how this should work is that it process power
	component_parts stores all the important components for this
	That affect the ais processing speed
	This should be linked to a datum
	*/
	var/datum/ai_queue/linked_queue

/obj/machinery/ai_server/Destroy(force)
	. = ..()
	linked_queue.remove_linked_server(src)
	return

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
	return default_deconstruction_crowbar(user, tool)

// /roundstart denotes the ai_servers spawned at roundstart
// The ones you map in, auto linked to the AI at roundstart
/obj/machinery/ai_server/roundstart/Initialize(mapload)
	. = ..()
	var/mob/living/silicon/ai/ai_player
	if(!(ai_player in GLOB.player_list))
		return

	linked_queue = ai_player.ais_queue
	linked_queue.add_linked_server(src)
