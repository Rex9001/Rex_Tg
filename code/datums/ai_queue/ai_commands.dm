/datum/ai_command
	/// The name of this command
	var/name = "Basic Ai Command"
	/// Amount of processing this command needs to execute
	var/process_required = 1
	/// Amount of processing we've done
	var/processing = 0
	/// if this command even exists
	var/live = TRUE

/// This runs on every processing from the ai_queue if the processing reaches the amount required the ai command will execute
/datum/ai_command/proc/progress(processing_amount)
	processing += processing_amount
	if(processing >= process_required)
		execute()

/// Do something
/datum/ai_command/proc/execute()
	processing = 0
	live = FALSE
	qdel(src)
