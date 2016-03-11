
//Creates and distributes viruses
/datum/terminal_command/provirus
	id = "provirus" //Get it? Because antiviruses are AGAINST viruses? Heh... I'll see myself out.
	desc = "Creates and distributes malicious software."
	requires_network_access = 1
	requires_cooldown = 1
	cooldown_time = 3000 //Five minutes, maybe too much?
	var/list/stored_viruses = list() //ids of viruses
	var/list/possible_viruses = list("PowerOverwhelming", "RemoveViro") //ids of viruses

/datum/terminal_command/provirus/execute()
	if(!check_command())
		return 0

	var/function = alert(parent_terminal.owner, "Create or distribute viruses?", "Provirus", "Create", "Distribute", "Virus Encyclopedia")
	if(!parent_terminal.has_owner())
		return 0

	switch(function)
		if("Create")
			var/list/possible_viruses = list("PowerOverwhelming", "RemoveViro")
			var/virus_to_create = input(parent_terminal.owner, "Choose a virus to create.", "Malware Fabrication") as null|anything in possible_viruses
			if(!virus_to_create)
				return 0
			if(!parent_terminal.has_owner())
				return 0
			stored_viruses += virus_to_create
			parent_terminal.print_message("Virus fabricated. Provirus is now rebooting. This will take five minutes.")
			run_cooldown()
			return 1

		if("Distribute")
			if(!stored_viruses.len)
				parent_terminal.print_message("No viruses in storage. Unable to continue.")
				return 0
			var/virus_to_send = input(parent_terminal.owner, "Choose a virus to send out.", "Malware Distribution") as null|anything in stored_viruses
			if(!virus_to_send)
				return 0
			if(!parent_terminal.has_owner())
				return 0
			var/terminal_to_infect = stripped_input(parent_terminal.owner, "Enter the ID of a terminal to infect with [virus_to_send].", "Malware Distribution")
			var/obj/machinery/terminal/T = terminals[terminal_to_infect]
			if(!T || (T && !T.net_access))
				parent_terminal.print_message("The entered ID was not found, or the terminal with that ID does not have network access. Unable to continue.")
				return 0
			if(T == parent_terminal)
				parent_terminal.print_message("This program cannot target itself. Unable to continue.")
				return 0
			T.add_command(virus_to_send)
			stored_viruses -= virus_to_send
			parent_terminal.print_message("Virus sent. Have a nice day.")
			return 1

		if("Cancel")
			return 0
	return 1



//Do I really need to explain? //Shit go boom
/datum/terminal_command/self_destruct
	id = "shake_the_room"
	desc = "Initiates self-destruct sequence."


/datum/terminal_command/self_destruct/execute()
	if(!check_command())
		return 0
	var/confirmation = alert(parent_terminal.owner, "Are you sure you want to self-destruct this terminal?", "Chick-Chicky Boom", "Proceed", "Cancel")
	if(!parent_terminal.has_owner())
		return 0
	switch(confirmation)
		if("Proceed")
			parent_terminal.print_message("<span class='warning'><b>Proceeding with self-obliteration. Have a pleasant day.</span>")
			message_admins("[parent_terminal.owner] initiated self-destruct on terminal [parent_terminal.terminal_id] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[parent_terminal.x];Y=[parent_terminal.y];Z=[parent_terminal.z]'>JMP</a>")
			log_game("[parent_terminal.owner] initiated self-destruct on terminal [parent_terminal.terminal_id]")
			parent_terminal.self_destruct()
			return 1

		if("Cancel")
			return 0
	return 1
