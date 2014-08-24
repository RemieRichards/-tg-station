
/obj/machinery/smart_computer
	name = "computer"
//	icon = 'icons/obj/smart_computers/machines.dmi'
	icon = 'icons/obj/computer.dmi'
//	icon_state = "frame"
	icon_state = "command"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 300

	var/list/datum/file/default_files = list()
//	var/obj/item/smart_computer/circuitboard/motherboard/mobo = null

	var/obj/item/smart_computer/storage/hard_disk/HDD = null
	var/obj/item/smart_computer/storage/removable/removable_storage = null
	var/obj/item/smart_computer/card_reader/card_reader = null
	var/obj/item/weapon/cell/backup_power = null

	var/datum/file/program/OS/OS = null
	var/datum/file/program/OS/DOS = null //Todo: Make this a piece of shit you don't want to use to encourage OS use instead of DOS.
										//Todo: Fill full of Console stuff, things to break the PC.


/////////
// New //
/////////
// Desc: New
// Used: New instances

/obj/machinery/smart_computer/New()
	..()
	if(!HDD)
		HDD = new /obj/item/smart_computer/storage/hard_disk (src)
		HDD.parent_computer = src
	if(!OS)
		OS = new /datum/file/program/OS/NTOS
		HDD.file_add(OS)

	for(var/F in default_files)
		if(ispath(F))
			var/datum/file/FF = new F ()
			HDD.file_add(FF)


///////////////////
// Parts missing //
///////////////////
// Desc: Proc for /Required/ Computer parts
// Used: file.can_use() and process()

/obj/machinery/smart_computer/proc/parts_missing()
	var/missing = 0
	/*if(!mobo)
		missing++*/
	return missing

/////////////
// Process //
/////////////
// Desc: Process
// Used: Master controller processing ticks

/obj/machinery/smart_computer/process()
	if(parts_missing())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(OS)
		OS.process()

	updateDialog()
	update_icon()

	return

//////////////
// Interact //
//////////////
// Desc: Interact
// Used: Attack_hand()

/obj/machinery/smart_computer/interact(var/mob/living/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(parts_missing())
		return

	if(OS)
		OS.interact(user)
	else if(DOS)
		DOS.interact(user)

/////////////////
// Attack hand //
/////////////////
// Desc: Attack hand
// Used: Click()

/obj/machinery/smart_computer/attack_hand(var/mob/living/user)
	if(!ishuman(user))
		return
	interact(user)

