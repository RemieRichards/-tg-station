

//Misc stuff for testing different aspects of smart_computer(s)


/obj/machinery/smart_computer/debug
	name = "Smart Computer"
	desc = "You feel smarter just looking at it!"
	default_files = list(/datum/file/program/Honk,/datum/file/program/Honk,/datum/file/program/Honk,/datum/file/program/Honk,/datum/file/program/Honk)


/datum/file/program/Honk
	file_name = "Honk"
	extension = ".exe"


/datum/file/program/Honk/execute(var/mob/user)
	user << "HONK"
	world << "the honk has landed"


/obj/machinery/smart_computer/CORRUPT_OS
	default_files = list(/datum/file/program/Honk,/datum/file/program/Honk)

/obj/machinery/smart_computer/CORRUPT_OS/New()
	..()
	OS.file_stats |= FILE_CORRUPT