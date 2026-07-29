// TEMPORARY BEFORE THE UI IS MADE AND SUCH
/datum/action/cooldown/pause
	name = "Pause"
	desc = "Pauses the queue, click to resume."
	button_icon = 'icons/mob/actions/actions_AI.dmi'
	button_icon_state = "ai_shell"
	// linked queue
	var/datum/ai_queue/linked_queue

/datum/action/cooldown/pause/Activate()
	if(!linked_queue)
		var/mob/living/silicon/ai/linkee = owner
		linked_queue = linkee.ais_queue

	if(!linked_queue.is_paused)
		to_chat(owner, span_notice("Queue paused."))
		linked_queue.is_paused = 1
		linked_queue.stop()
		return

	to_chat(owner, span_notice("Queue started."))
	linked_queue.is_paused = 0
	linked_queue.start()

