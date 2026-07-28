/obj/machinery/ai_server
	name = "AI server"
	/*
	Okay so how this should work is that it process power
	component_parts stores all the important components for this
	That affect the ais processing speed
	This should be linked to a datum
	*/
	var/datum/ai_queue/ais_que

/obj/machinery/ai_server/Initialize(mapload)
	. = ..()
	// TEMP CODE, it should get linked with an AI somehow. Perhaps through the ai clicking on it or multitooling a server
	var/mob/living/silicon/ai/ai_player
	if(!(ai_player in GLOB.player_list))
		return

	ais_que = ai_player.ais_queue
	ais_que.change_linked_servers(src)
