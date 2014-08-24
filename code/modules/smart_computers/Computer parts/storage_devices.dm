
/obj/item/smart_computer/storage
	name = "storage device"
//	icon = 'icons/obj/smart_computers/components.dmi'
	icon_state = "storage"
	var/obj/machinery/smart_computer/parent_computer = null
	var/max_memory_storage = 1024 //1MB
	var/stored_memory = 0
	var/list/datum/file/file_list = list()

/////////////////
// File remove //
/////////////////
// Desc: Removes a file
// Used: File.move_to()

/obj/item/smart_computer/storage/proc/file_remove(var/datum/file/F)
	if(!istype(F))
		return
	if(F in file_list)
		file_list -=  F

	F.parent_computer = null
	F.file_loc = null
	stored_memory -= F.file_size

//////////////
// File add //
//////////////
// Desc: Adds a file
// Used: File.move_to() File.copy_to()

/obj/item/smart_computer/storage/proc/file_add(var/datum/file/F)
	if(!istype(F))
		return
	file_list += F
	F.file_loc = src
	F.parent_computer = parent_computer
	stored_memory += F.file_size


/obj/item/smart_computer/storage/hard_disk
	name = "Hard disk drive"
	icon_state = "HDD"
	max_memory_storage = 1048576 //1024kb * 1024, a GB //May be overkill


/obj/item/smart_computer/storage/removable
	name = "Removable storage device"
	icon_state = "r_HDD"

/obj/item/smart_computer/storage/removable/floppy
	name = "Removable floppy disk"
	icon_state = "floppy"
	max_memory_storage = 512 //0.5MB