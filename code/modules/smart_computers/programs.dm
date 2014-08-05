
/datum/file/program
	name = "NotAVirus"
	extension = ".exe"
	file_icon_state = "virus_exe"
	var/prog_desc	= "FREE! MONEY! FREE! MONEY!"


/datum/file/program/proc/interact(var/mob/user)
	if(!..())
		return

	var/P_alert = alert(user,"Select an Interact option","File Interact","Execute","Copy","Move")
	if(P_alert)
		switch(P_alert)
			if("Execute")
				execute(user)
			if("Copy")
				copy_to_floppy(user)
			if("Move")
				move_to_floppy(user)


