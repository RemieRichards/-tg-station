
/datum/file/program/OS
	file_name = "LoseDos"
	extension = ".OS"
	file_icon_state = "OS"
	prog_desc	= "Jump to OS"
	file_stats = 0
	var/datum/file/program/program = null//Active program
	var/OS_locked = 0 //Whether the OS has been locked by the logged in user.
	var/datum/file/user_profile/logged_in = null
	var/list/datum/file/user_profile/OSUsers = list()
	var/list/extensions = list(".txt",".exe")

/datum/file/program/OS/NTOS
	file_name = "NTOS"
	file_icon_state = "NTOS"
	extensions = list(".txt",".exe",".NT")

/datum/file/program/OS/Syndicate
	file_name = "Syndicate Operating System"
	extension = ".SOS"
	file_icon_state = "SOS"
	extensions = list(".txt",".exe",".synd")

/////////////////////
// File priviliges //
/////////////////////
// Desc: Checks if the user has the priviliges for the file
// Used: can_use()

/datum/file/program/OS/file_priviliges(var/mob/living/user)
	if(logged_in && !OS_locked)
		return 1
	if(!logged_in || OS_locked && logged_in)
		if(login(user))
			return 1

	return 0

//////////////
// Interact //
//////////////
// Desc: Interact
// Used: parent_computer.interact()

/datum/file/program/OS/interact(var/mob/living/user)
	var/dat = ""
	dat += text("Welcome to [file_name]<br>\n")
	dat += text("\nActions:<br>\n")
	dat += text("<br>\n")

	if(parent_computer)
		if(parent_computer.HDD)
			var/rem_mem = parent_computer.HDD.max_memory_storage - parent_computer.HDD.stored_memory
			if(rem_mem >= 0)
				dat += text("HDD storage remaining: [rem_mem]KB<br>\n")

			dat += text("Programs on HDD:<br>\n")
			for(var/datum/file/F in parent_computer.HDD.file_list)
				if(istype(F))
					dat += text("<A href='?src=\ref[src];file=\ref[F]'>[F.file_name]</a><br>\n")


		if(parent_computer.removable_storage)
			var/rem_mem2 = parent_computer.removable_storage.max_memory_storage - parent_computer.removable_storage.stored_memory
			if(rem_mem2 >= 0)
				dat += text("Removable storage remaining: [rem_mem2]KB<br>\n")

			dat += text("<br>\nPrograms on Removable Storage:<br>\n")
			for(var/datum/file/FF in parent_computer.removable_storage)
				if(istype(FF))
					dat += text("<A href='?src=\ref[src];file=\ref[FF]'>[FF.file_name]</a><br>\n")

			dat += text("<A href='?src=\ref[src];remove_removable_storage=1'>Remove removable storage</a><br>\n")


	output2popup(user,dat)


///////////
// Topic //
///////////
// Desc: Topic
// Used: Called by Hrefs

/datum/file/program/OS/Topic(href, href_list)
	if(..(href,href_list))
		return

	if(href_list["login"])
		login(usr)
		update_comp()

	if(href_list["file_browser"])
		world << "[usr] is stupid"
		output2popup(usr,"TODO: HONK, GTFO OUT OF MY CODE")
		update_comp()

	if(href_list["file"])
		var/datum/file/poke = locate(href_list["file"])
		if(poke && poke.extension)
			if(poke.extension in extensions)
				pokeFile(poke,usr)
			else
				output2popup(usr,"[file_name] cannot read files with extension [poke.extension]!")
		update_comp()

	if(href_list["remove_removable_storage"])
		if(parent_computer.removable_storage)
			var/obj/item/smart_computer/storage/removable/R = parent_computer.removable_storage
			R.parent_computer = null
			output2popup(usr,"[parent_computer.removable_storage] has been disconnected from [parent_computer]")
			R.loc = get_turf(usr)
			parent_computer.removable_storage = null
		update_comp()




///////////////
// Poke File //
///////////////
// Desc: Connects a user with a file with appropriate checks
// Used: OS.Topic()

/datum/file/program/OS/proc/pokeFile(var/datum/file/poke,var/mob/living/user)
	user << "Poked [file_name]" //debug

	if(istype(poke) && istype(user))
		if(poke.can_use(user))
			if(poke != src)
				program = poke //make active program if not the active OS
			poke.interact(user)
		else
			output2popup(user,"You cannot interact with this file!")
			Crash(user,"SHIT")
	update_comp()

///////////
// Login //
///////////
// Desc: Login process for the OS, uses user_profile datums
// Used: OS.file_priveleges()

/datum/file/program/OS/proc/login(var/mob/living/user)
	var/login = 0
	var/last_fail = 0
	var/fails = 0
	var/datum/file/user_profile/useraccount = null
	var/log_pass = ""

	if(logged_in)
		if(OS_locked)
			useraccount = logged_in
		else
			return 1 //user logged in and not locked, no more code needed

	else
		useraccount = input("Choose an account to log into","Login") as null|anything in OSUsers

	if(!useraccount)
		return 0

	log_pass = useraccount.password

	var/input_pass

	while(!login)
		update_comp()
		if(!can_use(user))
			break

		if(fails >= 3)
			fails = 0
			last_fail = world.time

		while(last_fail + 300 >= world.time)
			continue

		input_pass = input("Please enter the password for [useraccount.username]","Password") as text
		if(!input_pass && log_pass)//If no password inputted, and the account has a password of 1 or more chars.
			output2popup(user,"Please input a password")
			continue

		if(input_pass != log_pass)
			output2popup(user,"Incorrect password!")
			fails++
			var/rem_tries = 3
			rem_tries -= fails
			if(rem_tries >= 0)
				output2popup(user,"Tries remaining: [rem_tries]")
			continue

		if(input_pass == log_pass)
			output2popup(user,"Password accepted!")
			login++

	if(login)
		if(useraccount != logged_in)
			logged_in = useraccount
		return 1
	return 0

/////////////
// Process //
/////////////
// Desc: process()
// Used: parent_computer.process()

/datum/file/program/OS/process()
	if(program)
		program.process()
	update_comp()


///////////
// Crash //
///////////
// Desc: Crashes the computer
// Used: For comedic effect/Gameplay and fun

/datum/file/program/OS/Crash(var/mob/living/user,var/why)
	output2popup(user,why)
	program = null

	if(parent_computer && parent_computer.HDD)
		for(var/datum/file/F in parent_computer.HDD)
			if(prob(33))
				F.file_stats |= FILE_CORRUPT


