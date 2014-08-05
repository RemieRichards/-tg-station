
/obj/machinery/smart_computer
	name = "computer"
	icon = 'icons/obj/smart_computers/machines.dmi'
	icon_state = "frame"
	density = 1
	anchored = 1
	use_powe = 1
	idle_power_usage = 250
	active_power_usage = 300

	var/datum/file/boot_to
	var/list/default_files
	var/obj/item/smart_computer/circuitboard/motherboard/mobo

	var/obj/item/smart_computer/storage/hard_disk/HDD
	var/obj/item/smart_computer/storage/removable/floppy_disk/floppy

	var/obj/item/smart_computer/card_reader/card_reader

	var/obj/item/weapon/cell/backup_power

	var/datum/file/program/program
	var/datum/file/program/OS/OS

	var/super_haX0r = 0



/obj/machinery/smart_computer/New()
	..()
	if(!HDD)
		HHD = new obj/item/smart_computer/storage/hard_disk ()
	if(!OS)
		OS = new /datum/file/program/OS/NTOS

	for(var/datum/file/F in default_files)
		var/datum/file/FF = new F ()
		FF.parent_computer = src
		FF.file_loc = HDD
		HDD.file_list += FF

	if(boot_to)
		var/datum/file/F = locate(boot_to) in HDD.file_list
		F.file_open()



/obj/machinery/smart_computer/proc/parts_missing()
	var/missing = 0
	if(!mobo)
		missing++


/obj/machinery/smart_computer/process()
	if(parts_missing())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(OS)
		OS.process()
	return

/obj/machinery/smart_computer/attack_hand(var/mob/user)
	if(!ishuman(user))
		return

	if(OS)
		if(program)
			program.execute(user)
		else
			OS.interact()

	..(user)



