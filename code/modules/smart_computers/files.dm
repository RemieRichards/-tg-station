
#define CAN_COPY 1
#define CAN_EDIT 2
#define CAN_MOVE 4

/datum/file
	var/file_name = "File"
	var/extension = ".data"
	var/file_size = 0
	var/file_icon = 'icons/obj/smart_computers/files_progs.dmi'
	var/file_icon_state = "corrupt_file"
	var/obj/machinery/smart_computer/parent_computer
	var/obj/item/smart_computer/storage/file_loc
	var/file_stats = CAN_MOVE | CAN_COPY | CAN_EDIT

/////////////
// Can use //
/////////////
// handles everything all the procs need to share for use

/datum/file/proc/can_use(var/mob/user)
	if(!parent_computer || parent_computer.stat & (NOPOWER|BROKEN))
		return 0
	if(parent_computer.parts_missing())
		return 0
	if(!file_loc)
		return 0
	if(!user)
		return 0
	if(!file_priviliges(user))
		return 0
	return 1

/////////////////////
// File priviliges //
/////////////////////
// Checks if the user has the priviliges for the file

/datum/file/proc/file_priviliges(var/mob/user)
	return 1

////////////////////
// Copy to device //
////////////////////
// copies a file to a device

/datum/file/proc/copy_to_floppy(var/mob/user)
	if(!can_use(user))
		return 0
	if(file_stats & CAN_COPY || parent_computer.super_haX0r)
		var/datum/file/F_copy = new type ()
		if(parent_computer.floppy)
			if(parent_computer.floppy.file_add(F_copy))
				user << browse("[name] succesfully copied to [floppy.name]!")
				return F_copy
	return 0

////////////////////
// Move to device //
////////////////////
// moves a file to a device

/datum/file/proc/move_to_floppy(var/mob/user)
	if(!can_use(user))
		return 0
	if(file_stats & CAN_MOVE || parent_computer.super_haX0r)
		if(floppy && file_loc)
			if(floppy == file_loc)
				user << browse("[name] is already on [floppy.name]!")
				return 0
			if(floppy.file_add(src))
				if(file_loc.file_remove(src))
					user << browse("[name] succesfully moved to [floppy.name]!")
					return src
	return 0

//////////
// Edit //
//////////
// edits a file

/datum/file/proc/edit(var/mob/user)
	if(!can_user(user))
		return 0
	if(file_stats & CAN_EDIT || parent_computer.super_haX0r)
		return 1

//////////////
// Interact //
//////////////
// branching options for the file

/datum/file/proc/interact(var/mob/user)
	if(!can_use(user))
		return 0
	return 1


