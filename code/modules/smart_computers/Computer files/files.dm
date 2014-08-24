
#define CAN_COPY 1
#define CAN_EDIT 2
#define CAN_MOVE 4
#define FILE_CORRUPT 8

/datum/file
	var/file_name = "File"
	var/extension = ".file"
	var/file_size = 0
//	var/file_icon = 'icons/obj/smart_computers/files_progs.dmi'
	var/file_icon_state = "corrupt_file"
	var/obj/machinery/smart_computer/parent_computer
	var/obj/item/smart_computer/storage/file_loc
	var/file_stats = CAN_MOVE | CAN_COPY | CAN_EDIT
	var/datum/browser/popup

/////////////
// Can use //
/////////////
// Desc: Handles everything all the procs need to share for use
// Used: Anywhere a file needs to check

/datum/file/proc/can_use(var/mob/living/user)
	if(!ishuman(user))
		if(!istype(user, /mob/living/silicon))
			return 0
	if(file_stats & FILE_CORRUPT)
		if(istype(src, /datum/file/program/OS))
			//output2popup(user,"Error: OS fatal runtime")
			//output2popup(user,"<table align='center' width='100%'><tr><td><img src='view_vars_sprite.png'></td>
			output2popup(user,"<table align='center' width='100%'><tr><td>##--1##a'#dws#ad###aa###--288jij</td><td>#2#2#--edta-##ru726do##h0Nk--uia-</td><td>##t7120--92814hfs###--#2##46klr#-</td></tr></table>")
		else
			output2popup(user,"Error: the file you are attempting to access is corrupted")

		return 0
	if(!parent_computer || parent_computer.stat & (NOPOWER|BROKEN))
		return 0
	if(parent_computer.parts_missing())
		return 0
	if(!file_loc)
		return 0
	if(!file_priviliges(user))
		return 0
	return 1

/////////////////////
// File priviliges //
/////////////////////
// Desc: Checks if the user has the priviliges for the file
// Used: can_use()

/datum/file/proc/file_priviliges(var/mob/living/user)
	return 1


/////////////
// Copy to //
/////////////
// Desc: Copies a file to a destination
// Used: File Topic()

/datum/file/proc/copy_to(var/mob/living/user,var/obj/item/smart_computer/storage/destination)
	if(!can_use(user))
		return 0
	if(file_stats & CAN_COPY)
		var/datum/file/F_copy = new type ()
		if(destination)
			if(destination.file_add(F_copy))
				output2popup(usr,"[file_name] succesfully copied to [destination]!")
				return F_copy
			else
				output2popup(usr,"[file_name] failed to copy, perhaps [destination] is full?")
				return 0
		else
			output2popup(usr,"No destination, missing HDD/Removable storage!")
			return 0
	else
		output2popup(usr,"[file_name] cannot be copied!")
	return 0

/////////////
// Move to //
/////////////
// Desc: Moves a file to a destination
// Used: File Topic()

/datum/file/proc/move_to(var/mob/living/user,var/obj/item/smart_computer/storage/destination)
	if(!can_use(user))
		return 0

	var/obj/item/smart_computer/storage/o_file_loc = file_loc //store current file loc, file_remove() get's rid of file_loc and we may need it below

	if(file_stats & CAN_MOVE)
		if(destination && file_loc)
			if(destination == file_loc)
				output2popup(usr,"[file_name] is already on [destination]!") //No dupes atm.
				return 0
			if(file_loc.file_remove(src))
				if(destination.file_add(src))
					output2popup(usr,"[file_name] succesfully moved to [destination]!")
					return src
				else
					output2popup(usr,"[file_name] failed to move, perhaps [destination] is full?")
					o_file_loc.file_add(src) // readd file to old loc.
					return 0

		else
			output2popup(usr,"No destination, missing HDD/Removable storage!")
			return 0
	else
		output2popup(usr,"[file_name] cannot be moved!")
	return 0

//////////
// Edit //
//////////
// Desc: Edits a file
// Used: Unused

/datum/file/proc/edit(var/mob/living/user)
	if(!can_use(user))
		return 0
	if(file_stats & CAN_EDIT)
		return 1

//////////////
// Interact //
//////////////
// Desc: Branching options for the file
// Used: OS.pokeFile()

/datum/file/proc/interact(var/mob/living/user)
	output2popup(user,"[file_name] opened!")//debug
	return 1

//////////////////
// Output2popup //
//////////////////
// Desc: All files have a popup
// Used: When outputting text/hrefs to User

/datum/file/proc/output2popup(var/mob/living/user,var/data)
	data += text("<br>\n<A href='?src=\ref[src];backbutton=1'>Back</a><br>\n") //add a quit/back button.

	if(!popup || popup.user != user)
		popup = new(user,"\ref[parent_computer]",file_name)

	popup.set_content(data)
	popup.open()

/////////////////
// Update comp //
/////////////////
// Desc: Updates the computer's dialogs and icons
// Used: Href's and OS.process()

/datum/file/proc/update_comp()
	if(parent_computer)
		parent_computer.updateDialog()
		parent_computer.update_icon()

	world << "Update_comp() called at [world.time]" //Debug

///////////
// Topic //
///////////
// Desc: Topic
// Used: Called by Hrefs

/datum/file/Topic(href,href_list)
	if(!can_use(usr))
		return 1

	if(href_list["backbutton"])
		if(parent_computer)
			if(parent_computer.OS)
				if(parent_computer.OS.program) //Active program preferred over OS
					parent_computer.OS.pokeFile(parent_computer.OS.program,usr)
					return 0

				parent_computer.OS.program = null
				parent_computer.OS.pokeFile(parent_computer.OS,usr)
				return 0