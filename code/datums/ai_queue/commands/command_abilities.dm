// TEMP CODE UNTIL UI
/datum/action/cooldown/command
	name = "Generic command"
	desc = "Generic command"
	// The queue this datum is linked to
	var/datum/ai_queue/linked_queue
	// The command this action executes
	var/datum/ai_command/linked_command

/datum/action/cooldown/command/Grant(mob/grant_to)
	// DO NOT GIVE THIS TO NON-AIS
	if(!istype(grant_to, /mob/living/silicon/ai))
		return
	var/mob/living/silicon/ai/linkee = grant_to
	linked_queue = linkee.ais_queue
	return ..()

/datum/action/cooldown/command/Activate()
	linked_queue.add_command(linked_command)
