// In the future this should maybe be able to do any airlock command to a large scale area
/// A command the AI uses to open all doors in an area
/datum/ai_command/sesame
	name = "Large Scale Door Opening"
	process_required = 50

	/// Area we are opening all doors in
	var/atom/focus
	/// The AI opening the doors
	var/mob/living/silicon/ai/owner

/datum/ai_command/sesame/New(atom/target, mob/living/silicon/ai/user)
	. = ..()

	focus = target
	owner = user
	var/area/focus_area = get_area(focus)
	name = "[focus_area.name] large doors opening"

/datum/ai_command/sesame/execute()
	var/list/o_range = orange(10, focus)
	for(var/obj/machinery/door/airlock/door in o_range)
		INVOKE_ASYNC(door, TYPE_PROC_REF(/atom, AIShiftClick), owner)

	return ..()
