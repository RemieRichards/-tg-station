/*
Terminals: more advanced versions of computers. Rather than simple press-button-do-thing, terminals have various commands and are more capable of certain actions.
This file contains:
 -Terminals
 -Terminal modems
 -Program disks
 -Terminal electronics
 -Terminal construction
*/

var/global/list/terminals = list() //All terminals in the game world
var/global/list/random_malware = list("GreatDeals", "CourierCrusher") //Viruses randomly gained fom the network
var/global/list/terminal_commands_types = list()

/proc/init_terminal_commands()
	for(var/cmd in subtypesof(/datum/terminal_command))
		var/datum/terminal_command/CMD = cmd
		terminal_commands_types[initial(CMD.id)] = cmd


/obj/machinery/terminal
	name = "terminal"
	desc = "A computer terminal developed by TLWM (Think Less Work More) Information Technologies. It uses an on-screen keyboard and touch-based display."
	icon = 'icons/obj/machines/terminal.dmi'
	icon_state = "terminal"
	density = 1
	opacity = 0
	anchored = 1
	var/mob/living/owner = null //The person using the terminal. Can be synthetic or human.
	//Commands
	var/list/loaded_commands = list() //Assoc list loaded_commands[command.id] = command
	var/list/processing_commands = list() //terminal_commands that execute_process() in the computer's process() eg: Viruses
	var/list/starting_commands = list("help", "orientation", "shutdown")//List of paths or IDs, starting commands for this terminal
	//Access
	var/net_access = 0 //Does the terminal have network access?
	var/robot_access = 0 //Will this terminal allow synthetic lifeforms to access it?
	//Misc
	var/online = 0 //Is the terminal turned on?
	var/terminal_id = "" //The ID of the terminal
	var/static/terminal_id_source = 0 //used to generate IDs
	var/health = 25 //How much punishment the terminal can take before smashing
	var/max_health = 25
	var/broken = 0 //Will the terminal not function?
	var/self_destructing = 0 //Is it fucking exploding?
	var/syndicate = 0 //Is the terminal hacked/modified by Syndicate industries?


/obj/machinery/terminal/public //Standard terminal used in public areas. Not important enough to warrant an antivirus.
	starting_commands = list("help", "orientation", "shutdown", "mail", "list")
	net_access = 1


/obj/machinery/terminal/personal //Standard terminal used in private areas like offices.
	starting_commands = list("help", "orientation", "shutdown", "mail", "list", "antivirus")
	net_access = 1


/obj/machinery/terminal/syndicate //A modified terminal used for illicit actions. Equipped with a self-destruct in case of compromisation
	desc = "A computer terminal developed by Cybersun Industries. It uses an on-screen keyboard and touch-based display." //Different examine text for the attentive
	starting_commands = list("help", "syndicate_orientation", "shutdown", "mail", "list", "shake_the_room", "provirus")
	syndicate = 1
	net_access = 1


/obj/machinery/terminal/New()
	..()
	for(var/I in starting_commands)
		add_command(I)
	if(!terminal_id) //unique mapped terminals could use ids as a way for the mapper to remember the terminal's purpose eg: "Spooky PC"
		terminal_id = "[++terminal_id_source]"
	terminals[terminal_id] = src


/obj/machinery/terminal/Destroy()
	terminals[terminal_id] = null
	..()


/obj/machinery/terminal/process()
	if(owner && online)

		for(var/cmd in processing_commands)
			var/datum/terminal_command/CMD = cmd
			CMD.execute_process()

		if(net_access)
			if(prob(0.5)) //Very low chance to be come infected with a virus from the network; typically normal/basic
				if(random_malware.len)
					add_command(pick(random_malware))

				if(has_command("antivirus") && prob(25))
					print_message("<span class='warning'>Possible threat detected. It is recommended that you run a virus scan.</span>")
		if(!has_owner())
			owner = null
			update_power(0)


/obj/machinery/terminal/attack_hand(mob/user)
	if((ishuman(user) || issilicon(user)) && user.canUseTopic(src))
		if(self_destructing)
			if(issilicon(user))
				user << "<span class='warning'>Terminal self-destruct protocol is in progress. Unable to interface.</span>"
			else
				user << "<span class='warning'>Shouldn't you be running?!</span>"
			return 0
		if(broken)
			user << "<span class='warning'>[src] is broken!</span>"
			return 0
		if(panel_open)
			user << "<span class='warning'>You can't use [src] while its panel is open!</span>"
			return 0
		if(owner && owner != user)
			user << "<span class='warning'>Someone is already using this [name]!</span>"
			return 0
		if(!online)
			if(has_command("RemoveViro") && user.mind.assigned_role == "Virologist")
				user << "<span class='warning'>You turn on [src], but suddenly...!</span>"
				update_power(1)
				say("REMOVE VIRO REMOVE VIRO you are the worst viro")
				self_destruct()
				return 0
			if(syndicate)
				if(!user.mind.special_role) //Any antagonist can get into the terminal
					user << "<span class='warning'>This [name] doesn't seem to work properly.</span>"
					return 0
			user.visible_message("<span class='notice'>[user] turns on [src].</span>", "<span class='notice'>You turn on [src].</span>")
			owner = user
			update_power(1)
			return 1
		command_line()


/obj/machinery/terminal/attackby(obj/item/I, mob/living/user, params)
	if(broken)
		if(!istype(I, /obj/item/weapon/weldingtool))
			user << "<span class='warning'>[src] is broken!</span>"
			return 0
		var/obj/item/weapon/weldingtool/W = I
		if(!W.isOn())
			user << "<span class='warning'>Turn on [W] first!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] begins repairing [src]...</span>", "<span class='notice'>You begin restoring the broken [name]...</span>")
		playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
		user.flash_eyes(W.light_intensity)
		if(!do_after(user, 100, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] repairs [src]!</span>", "<span class='notice'>You restore [src] to working condition!</span>")
		playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
		icon_state = "terminal"
		broken = 0
		health = max_health
		update_icon()
		return 1

	if(istype(I, /obj/item/weapon/pen))
		var/new_id = stripped_input(user, "What would you like to change this terminal's ID to?", "ID Change")
		if(!new_id || !user.canUseTopic(src))
			return 0
		user.visible_message("<span class='notice'>[user] changes [src]'s id to \"[new_id]\".</span>", "<span class='notice'>You change [src]'s ID to \"[new_id]\".")
		terminal_id = new_id
		if(has_command("GreatDeals"))
			print_message("<span class='warning'>Are you sure you want to miss out on all these great deals? >Y</span>")
			cleanse_virus("GreatDeals")
		return 1

	else if(istype(I, /obj/item/weapon/screwdriver))
		if(online)
			user << "<span class='warning'>You can't open the maintenance panel while [src] is on!</span>"
			return 0
		panel_open = !panel_open
		user.visible_message("<span class='notice'>[user] [panel_open ? "open" : "close"] [src]'s panel.</span>", "<span class='notice'>You [panel_open ? "open" : "close"] [src]'s panel.</span>")
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, 1)
		return 1

	else if(istype(I, /obj/item/weapon/wirecutters))
		if(!panel_open)
			user << "<span class='warning'>Open the panel first!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] removes [src]'s network modem.</span>", "<span class='notice'>You remove the network modem from [src].</span>")
		playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 25, 1)
		net_access = 0
		new /obj/item/terminal/modem (get_turf(src))
		return 1

	else if(istype(I, /obj/item/weapon/crowbar))
		if(!panel_open)
			user << "<span class='warning'>Open the panel first!</span>"
			return 0
		if(net_access)
			user << "<span class='warning'>The modem is in the way!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] begins prying out [src]'s display...</span>", "<span class='notice'>You begin prying out [src]'s display...</span>")
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
		if(!do_after(user, 50, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] pries out [src]'s display!</span>", "<span class='notice'>You remove the display from [src].</span>")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		var/obj/item/stack/sheet/glass/G = new(get_turf(src))
		G.amount = 1
		var/obj/structure/terminal_casing/T = new(get_turf(src))
		T.construction_state = 3 //Needs glass
		T.update_icon()
		qdel(src)
		return 1

	else if(istype(I, /obj/item/terminal/modem))
		if(!panel_open)
			user << "<span class='warning'>Open the panel first!</span>"
			return 0
		if(net_access)
			user << "<span class='warning'>This [name] already has a network modem!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] inserts [I] into [src].</span>", "<span class='notice'>You install [I].</span>")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
		net_access = 1
		user.drop_item()
		qdel(I)
		return 1

	else if(istype(I, /obj/item/terminal/program_disk))
		var/obj/item/terminal/program_disk/P = I
		if(!P.loaded_program)
			var/program_to_copy = input(user, "Select a program to copy.", "Program Disk") as null|anything in loaded_commands
			if(!program_to_copy || !user.canUseTopic(src))
				return 0
			user << "<span class='notice'>You copy \"[program_to_copy]\" onto [P].</span>"
			P.loaded_program = program_to_copy
			P.icon_state = "disk_filled"
		else if(P.loaded_program)
			if(loaded_commands[P.loaded_program])
				user << "<span class='warning'>That program is already on this [name]!</span>"
				return 0
			user << "<span class='notice'>You copy \"[P.loaded_program]\" onto [src].</span>"
			add_command(P.loaded_program)
		return 1

	else if(I.force && user.a_intent == "harm")
		user.visible_message("<span class='warning'>[user] slams [I] into [src]'s display!</span>", "<span class='danger'>You strike [src] with [I]!</span>")
		health -= I.force
		switch(I.force)
			if(1 to 5)
				visible_message("<span class='warning'>[src] display chips.</span>")
				playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 30, 1)
			if(6 to 15)
				visible_message("<span class='warning'>[src] display stars.</span>")
				playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 50, 1)
			if(16 to 24)
				visible_message("<span class='warning'>Part of [src]'s display shears off.</span>")
				playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 70, 1)
			if(25)
				visible_message("<span class='warning'><b>[src]'s display shatters!</b></span>")
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 90, 1)
		health = Clamp(health, 0, max_health)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if(health <= 0)
			break_terminal()
		return 1
	..()


/obj/machinery/terminal/attack_ai(mob/user)
	if(!robot_access)
		user << "<span class='warning'>[src] is configured to prevent access by synthetic lifeforms!</span>"
		return 0
	attack_hand(user)


/obj/machinery/terminal/examine(mob/user)
	..()
	if(!panel_open)
		if(online)
			user << "A green light on the tower is [net_access ? "flickering" : "off"]."
			user << "A blue light on the tower is [robot_access ? "glowing steadily" : "off"]."
		else
			if(!broken)
				user << "It seems to be turned off."
			else
				user << "<span class='warning'>Its display is shattered and its monitor is dented.</span>"
	else if(panel_open)
		user << "Its maintenance panel is open."
		if(net_access)
			user << "There is a network modem inside of the terminal."
		else
			user << "It's missing a network modem."
	user << "The terminal's ID is written on a label: [terminal_id]."


/obj/machinery/terminal/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			break_terminal()
		if(3)
			break_terminal()


/obj/machinery/terminal/proc/print_message(message, print_text)
	if(!message || !owner || !online)
		return 0
	owner << "<i>[print_text ? "[print_text]" : "[src] displays"]:</i> <span class='robot'>[message]</span>"
	return 1


/obj/machinery/terminal/proc/update_power(intention)
	if(self_destructing)
		return 0
	switch(intention)
		if(0)
			if(online)
				idle_power_usage = 0
				overlays.Cut()
				online = 0
		if(1)
			if(!online)
				idle_power_usage = 100
				overlays += image('icons/obj/machines/terminal.dmi', "screen_[syndicate]")
				online = 1
	update_icon()
	return 1



/obj/machinery/terminal/proc/add_command(path_or_id)
	if(!path_or_id)
		return 0
	var/cid
	if(ispath(path_or_id))
		var/datum/terminal_command/command_path = path_or_id
		cid = initial(command_path.id)
	else
		cid = path_or_id
	var/ctype = terminal_commands_types[cid]
	if(loaded_commands[cid] || !ctype)
		return 0
	else
		var/datum/terminal_command/CMD = new ctype ()
		CMD.parent_terminal = src
		if(CMD.processes)
			processing_commands[cid] = CMD
		loaded_commands[cid] = CMD
		return 1
	return 0


/obj/machinery/terminal/proc/parse_command(command_id)
	if(!online)
		return 0
	var/datum/terminal_command/C = loaded_commands[command_id]
	if(istype(C))
		log_game("Terminal [terminal_id] ran command \"[C]\"")
		C.execute()
		return 1
	print_message("The entered command is either not accessible or not loaded on this terminal. Unable to continue.")
	return 0


/obj/machinery/terminal/proc/has_command(command_id)
	var/datum/terminal_command/C = loaded_commands[command_id]
	if(istype(C))
		return C
	return 0


/obj/machinery/terminal/proc/remove_command(command_id)
	var/datum/terminal_command/C = loaded_commands[command_id]
	if(istype(C))
		loaded_commands[command_id] = null
		loaded_commands -= command_id
		processing_commands[command_id] = null
		processing_commands -= command_id
		qdel(C)
		return 1
	return 0


/obj/machinery/terminal/proc/cleanse_virus(virus_id)
	if(remove_command(virus_id))
		print_message("<span class='notice'>Malware has been successfully removed from this terminal.</span>")
		return 1
	return 0


/obj/machinery/terminal/proc/command_line()
	if(!owner)
		return 0
	var/input = stripped_input(owner,"Type \"help\" for a list of installed commands.","TLWMIT Terminal - [terminal_id]")
	if(!input || !has_owner())
		return 0
	parse_command(input)
	if(online)
		command_line() //If the terminal wasn't shut down, keep at it
	return 1


/obj/machinery/terminal/proc/send_message(message, target, obfuscate_source)
	if(!message || !target)
		return 0
	var/obj/machinery/terminal/T = terminals[target]
	if(!T)
		return 0
	if(T.terminal_id == target && T.net_access)
		if(has_command("CourierCrusher") || T.has_command("CourierCrusher"))
			return 0
		var/datum/terminal_command/mail/mail = T.has_command("mail")
		if(!mail)
			print_message("The found terminal does not have mail access. Unable to continue.")
			return 0
		log_game("Terminal [terminal_id] sent \"[message]\" to terminal [target]; sender ID was [obfuscate_source ? "" : "not"] hidden from recipient")
		T.say("New message received!")
		playsound(get_turf(T), 'sound/machines/twobeep.ogg', 75, 1)
		mail.inbox.Add("[obfuscate_source ? "\[UNKNOWN\]" : "Terminal [terminal_id]"]: \"[message]\" (received at [worldtime2text()])")
		return 1
	print_message("There is no terminal with the entered ID. Unable to continue.")
	return 0


/obj/machinery/terminal/proc/break_terminal()
	if(broken)
		return 0
	visible_message("<span class='warning'>[src]'s shattered display emits a flurry of sparks!</span>")
	playsound(get_turf(src), "sparks", 50, 1)
	broken = 1
	update_power(0)
	icon_state = "broken"
	update_icon()
	return 1


/obj/machinery/terminal/proc/has_owner()
	if(!owner || !owner.canUseTopic(src))
		return 0
	return 1


/obj/machinery/terminal/proc/self_destruct() //Of course they can self-destruct! What did you expect?
	if(broken)
		return 0
	message_admins("Terminal [terminal_id] initiated self-destruct! <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>")
	log_game("Terminal [terminal_id] self-destructed!")
	audible_message("<span class='warning'>[src] begins to beep ominously!</span>")
	overlays.Cut()
	overlays += image('icons/obj/machines/terminal.dmi', "screen_selfdestruct")
	self_destructing = 1
	for(var/i = 0, i < 3, i++)
		playsound(get_turf(src), 'sound/items/timer.ogg', 50, 0)
		sleep(10)
	if(prob(1) && !syndicate) //Very low chance to be a dud, but Syndicate ones always explode
		visible_message("<span class='warning'>[src] falls silent. Looks like it was a dud!</span>")
		return 1
	if(syndicate)
		visible_message("<span class='boldannounce'>[src] implodes in a flash of blinding crimson light!</span>")
		explosion(get_turf(src), 1, 3, 5, 5) //A bit better than a minibomb
	else
		visible_message("<span class='boldannounce'>[src] blows apart!</span>")
		explosion(get_turf(src), 0, 2, 4, 0)
	if(src)
		qdel(src)


//Terminal items
/obj/item/terminal
	name = "fake terminal"
	desc = "This shouldn't exist."
	icon = 'icons/obj/machines/terminal.dmi'
	icon_state = "terminal"
	w_class = 2


//Terminal modems: required to connect a terminal to the network. Most terminals start with one, and more can be printed from an autolathe.
/obj/item/terminal/modem
	name = "terminal modem"
	desc = "A specialized device for sending and receiving wireless signals. Used in terminals to provide network access."
	icon_state = "modem"


//Program disks: specialized disks used to copy programs onto terminals and vice-versa.
/obj/item/terminal/program_disk
	name = "program disk"
	desc = "A little disk used to copy and transfer programs from one terminal to another. Self-powered with a built-in display."
	icon_state = "disk_empty"
	w_class = 1
	var/loaded_program = null //The program that the disk is currently holding


/obj/item/terminal/program_disk/attack_self(mob/user)
	if(!loaded_program)
		return ..()
	var/wipe_program = alert("Wipe the disk's loaded program?.", name, "Wipe", "Cancel")
	if(wipe_program == "Wipe")
		user << "<span class='notice'>You reset [src]'s memory.</span>"
		loaded_program = null
		icon_state = "disk_empty"
	return 1


/obj/item/terminal/program_disk/examine(mob/user)
	..()
	if(!loaded_program)
		user << "It doesn't currently have a program written to it."
	else
		user << "The miniature display indicates that the \"[loaded_program]\" program is ready for transfer."


//Terminal electronics: used in construction of terminals.
/obj/item/weapon/electronics/terminal
	name = "terminal electronics"
	desc = "A central circuit used in terminals. Loaded with TLWMIT's terminal OS and uses simplistic design to allow for easy production."
	materials = list(MAT_METAL = 75, MAT_GLASS = 150)

/*
Terminal construction. Steps below.
	1. Build a terminal casing with five sheets of metal
	2. Add wiring to the tower
	3. Add a circuit board to the tower
	4. Add glass to the display
	5. Screwdriver to finish

Deconstruction:
	1. Open a terminal's panel
	2. Use a crowbar to pry out the monitor's glass
	3. Pry out the circuit board
	4. Cut out the wires
	5. Weld apart the casing
*/

#define NEEDS_WIRES 1
#define NEEDS_ELECTRONICS 2
#define NEEDS_GLASS 3


//Terminal casings, used to build terminals
/obj/structure/terminal_casing
	name = "terminal casing"
	desc = "Empty casing used to house a terminal."
	icon = 'icons/obj/machines/terminal.dmi'
	icon_state = "construction_1"
	density = 1
	anchored = 0
	opacity = 0
	var/construction_state = NEEDS_WIRES


/obj/structure/terminal_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		anchored = !anchored
		user.visible_message("<span class='notice'>[user] [anchored ? "" : "un"]secures [src].</span>", "<span class='notice'>You [anchored ? "" : "un"]secure [src].</span>")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		return 1
	if(!attempt_construction(user, I))
		..()


/obj/structure/terminal_casing/examine(mob/user)
	..()
	switch(construction_state)
		if(NEEDS_WIRES)
			user << "It's missing wires."
		if(NEEDS_ELECTRONICS)
			user << "It's missing electronics."
		if(NEEDS_GLASS)
			user << "It's missing a display."


/obj/structure/terminal_casing/proc/attempt_construction(mob/living/user, obj/item/I)
	switch(construction_state)
		if(NEEDS_WIRES)
			if(istype(I, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = I
				if(C.amount < 8)
					user << "<span class='warning'>You need at least eight wires to wire [src]!</span>"
					return 1
				user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", "<span class='notice'>You begin wiring [src]...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(!do_after(user, 20, target = src))
					return 1
				user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", "<span class='notice'>You wire [src].</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				C.amount -= 8
				if(C.amount <= 0)
					user.drop_item()
					qdel(C)
				construction_state = NEEDS_ELECTRONICS
				update_icon()
				return 1

			else if(istype(I, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/W = I
				if(!W.isOn())
					user << "<span class='warning'>Turn on [W] first!</span>"
					return 1
				user.visible_message("<span class='notice'>[user] begins slicing apart [src]...</span>", "<span class='notice'>You begin cutting apart [src]...</span>")
				playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
				user.flash_eyes(W.light_intensity)
				if(!do_after(user, 50, target = src))
					return 1
				user.visible_message("<span class='notice'>[user] slices apart [src]!</span>", "<span class='notice'>You cut [src] into metal sheets.</span>")
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
				playsound(get_turf(src), "trayhit", 50, 1) //Metal clanging
				var/obj/item/stack/sheet/metal/M = new(get_turf(src))
				M.amount = 5
				qdel(src)
				return 1

		if(NEEDS_ELECTRONICS)
			if(istype(I, /obj/item/weapon/electronics/terminal)) //Fast because it just snaps in
				user.visible_message("<span class='notice'>[user] installs [I] into [src].</span>", "<span class='notice'>You click [I] into place inside [src].</span>")
				user.drop_item()
				qdel(I)
				construction_state = NEEDS_GLASS
				update_icon()
				return 1

			else if(istype(I, /obj/item/weapon/wirecutters))
				user.visible_message("<span class='notice'>[user] begins gutting [src] of wires...</span>", "<span class='notice'>You begin cutting the wires from [src]...</span>")
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				if(!do_after(user, 30, target = src))
					return 1
				user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", "<span class='notice'>You dewire [src].</span>")
				var/obj/item/stack/cable_coil/C = new(get_turf(src))
				C.amount = 8
				construction_state = NEEDS_WIRES
				update_icon()
				return 1

		if(NEEDS_GLASS)
			if(istype(I, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = I //Only needs one sheet - don't check the amount
				user.visible_message("<span class='notice'>[user] begins adding glass to [src]'s display...</span>", "<span class='notice'>You begin adding glass to [src]'s display...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(!do_after(user, 25, target = src))
					return 1
				user.visible_message("<span class='notice'>[user] finishes the terminal!</span>", "<span class='notice'>You finish the terminal!</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				G.amount -= 1
				if(G.amount <= 0)
					user.drop_item()
					qdel(G)
				var/obj/machinery/terminal/T = new (get_turf(src))
				T.say("Hello World!")
				qdel(src)
				return 1

			else if(istype(I, /obj/item/weapon/crowbar))
				user.visible_message("<span class='notice'>[user] begins prying out [src]'s electronics...</span>", "<span class='notice'>You begin removing [src]'s electronics...</span>")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(!do_after(user, 50, target = src))
					return 1
				user.visible_message("<span class='notice'>[user] carefully removes [src]'s eonectrics.</span>", "<span class='notice'>You remove [src]'s electronics.</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				new /obj/item/weapon/electronics/terminal (get_turf(src))
				construction_state = NEEDS_ELECTRONICS
				update_icon()
				return 1
	return 0


/obj/structure/terminal_casing/update_icon()
	icon_state = "construction_[construction_state]"
	..()

#undef NEEDS_WIRES
#undef NEEDS_ELECTRONICS
#undef NEEDS_GLASS
