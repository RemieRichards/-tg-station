
/datum/file/program
	file_name = "NotAVirus"
	extension = ".exe"
	file_icon_state = "virus_exe"
	var/prog_desc	= "FREE! MONEY! FREE! MONEY!"

//////////////
// Interact //
//////////////
// Desc: Interact
// Used: OS.pokeFile()

/datum/file/program/interact(var/mob/living/user)
	var/dat = ""
	dat += text("[file_name]<br>\n")
	dat += text("[prog_desc]<br>\n")
	dat += text("Program Interactions:<br>\n")
	dat += text("<br>\n")
	dat += text("<A href='?src=\ref[src];execute=1'>Execute Program</a><br>\n")

	if(parent_computer && parent_computer.removable_storage && parent_computer.HDD)
		if(file_loc != parent_computer.removable_storage)
			dat += text("<A href='?src=\ref[src];move=[parent_computer.removable_storage]'>Move Program to removable storage</a><br>\n")
			dat += text("<A href='?src=\ref[src];copy=[parent_computer.removable_storage]'>Copy Program to removable storage</a><br>\n")
		else
			dat += text("<A href='?src=\ref[src];move=[parent_computer.HDD]'>Move Program to HDD</a><br>\n")
			dat += text("<A href='?src=\ref[src];copy=[parent_computer.HDD]'>Copy Program to HDD</a><br>\n")
	else
		dat += text("<br>\nNo removable storage inserted\n")

	output2popup(user,dat)

///////////
// Topic //
///////////
// Desc: Topic
// Used: Called by Hrefs

/datum/file/program/Topic(href,href_list)
	if(..(href,href_list))
		return

	if(href_list["execute"])
		execute(usr)
	if(href_list["copy"])
		var/obj/item/smart_computer/storage/C_Where = locate(href_list["copy"])
		if(C_Where)
			copy_to(usr,C_Where)
	if(href_list["move"])
		var/obj/item/smart_computer/storage/M_Where = locate(href_list["move"])
		if(M_Where)
			move_to(usr,M_Where)

/////////////
// Process //
/////////////
// Desc: Process
// Used: OS.process()

/datum/file/program/proc/process()
	return 1

/////////////
// Execute //
/////////////
// Desc: Execute the program
// Used: For a program's feature, eg: Cameras

/datum/file/program/proc/execute(var/mob/living/user)
	if(!can_use(user))
		return

	output2popup(user,"Program: [file_name] executed!")


///////////
// Crash //
///////////
// Desc: Crashes the computer
// Used: For comedic effect/Gameplay and fun

/datum/file/program/proc/Crash(var/mob/living/user,var/why)
	if(user && why)
		output2popup(user,why)

	if(parent_computer && parent_computer.OS)
		parent_computer.OS.program = null