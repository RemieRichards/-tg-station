
//Standard commands, usually included with the terminal


//Displays the commands loaded onto the terminal
/datum/terminal_command/help
	id = "help"
	desc = "Shows this menu." //Only shown in the help menu anyway


/datum/terminal_command/help/execute()
	if(!check_command())
		return 0
	var/help_text = "\n<b>Loaded commands:</b>"
	for(var/cid in parent_terminal.loaded_commands)
		var/datum/terminal_command/C = parent_terminal.loaded_commands[cid]
		if(C)
			help_text += "\n[C.id] - [C.desc] [C.requires_network_access ? "(requires network access)" : ""]"
	parent_terminal.print_message(help_text)


//Walks the user through the basics of terminal usage
/datum/terminal_command/orientation
	id = "orientation"
	desc = "A basic orientation on the TLWMIT terminal and its functionalities."


/datum/terminal_command/orientation/execute()
	if(!check_command())
		return 0
	var/orientation_text = "\n<b>TLWMIT Terminal Orientation</b>\n\n \
	Welcome to the orientation for the TLWMIT Terminal(tm)! Since Time Is Money(tm), we'll keep it Short And Sweet(tm). \n \
	First of all, terminals will automatically turn off when nobody is nearby. This is to conserve power and ensure longevity. \n \
	Terminals must be manually turned on by anyone wishing to use them. The terminal will then temporarily consider this person its \"owner\". \n \
	When this occurs, nobody can use the terminal except for the owner; anyone else will find the touch-based display unresponsive. \n \
	The owner is reset when they either leave the terminal or become incapable of continuing to use it (moving away, falling, etc.) \n \
	Second, terminals are capable of accessing a station or ship-wide network through which information can be transmitted. \n \
	In most cases, this is done with a specially-developed modem inside of the tower that both generates outgoing signals and receives incoming signals. \n \
	There is a unique slot for this modem, and any terminal lacking wireless fidelity can gain it by simply installing a modem, and vice-versa. \n \
	Third, terminals are often specialized and come with certain programs. New programs can be copied to the terminal by finding a program disk and copying its contents. \n \
	Fourth, certain lights on the tower indicate certain things. The green light represents whether or not the terminal is connected to the network, and the blue light represents \
	whether or not synthetic lifeforms are capable of accessing the terminal's interface. \n \
	Terminals can easily be constructed and deconstructed, but be warned: all data, including any non-default programs, will be lost during deconstruction! \n \
	As a final pointer, all terminal items (modems, electronics...) can be printed from an autolathe. \n \
	That's the basics of using a terminal. We hope you enjoy using our product!"
	parent_terminal.print_message(orientation_text, "[parent_terminal] briefly displays a a brain with a knife through it before loading")
	return 1



//Syndicate version of the standard orientation //Ok so it's not "standard" but it's standard for syndi terminals
/datum/terminal_command/syndicate_orientation
	id = "syndicate_orientation"
	desc = "A basic orientation on the Cybersun Industries terminal and its functionalities."


/datum/terminal_command/syndicate_orientation/execute()
	if(!check_command())
		return 0
	var/orientation_text = "\n<b>Cybersun Industries Welcomes You!</b>\n\n\
	Let's cut to the chase. The only reason you're seeing this orientation and aren't a screaming human torch with metal shards in your eyes is because you're either part of the Syndicate \
	or you're affiliated in some way with them. Long story short, you're against Nanotrasen, and that means that you can get into this terminal. I'm not going to bother you with any of the \
	normal terminal bullshit, since you probably know that, and if you don't, go find one of the TL pieces of crap and look at that. This terminal has a few functionalities that they've \
	left out because Nanotrasen's puppets aren't the kind of guys for corporate espionage, so here's what they are.\n\n\
	\
	Long story short, this terminal can only be accessed by someone who isn't affiliated with Nanotrasen. Don't ask how we do it - those Tiger bastards creep me out, I don't know what \
	kind of Exolitic crap they load these things with, but our terminals are password-locked, and if you're a corporate enemy, you'll realize you knew the password all along. One downside of this \
	is that the screen glows red all the time - what, you didn't seriously think we made it red for the hell of it? Anyway, since the crystals or whatever are also pretty unstable, it means \
	that the self-destruct function - which we conveniently loaded on-board - is a <i>lot</i> more powerful. I mean, once you turn it on, get the hell out unless you like being sucked \
	into space.\n\n\
	\
	Moving on, you know those viruses that go around all the time? You know, like CourierCrusher and whatnot? Well, Cybersun terminals aren't affected by them. Not only that, but the viruses \
	are actually <i>stored</i> and can be sent out to any other terminal on the network. Pretty handy stuff, and it's even untraceable to boot. There's also a few different types of virus \
	that can actually be made and sent out from the terminal itself. These aren't chain-mail pieces of crap - they're the real deal and can do things you didn't even know could be done to \
	terminals. You can't do this much - these things are expensive to develop - but what you <i>do</i> use will probably have an impact unless you just waste it on the clown or whatever.\n\n\
	\
	This is getting long, and my supervisor is getting bitchy, so I'll wrap this up with a few pointers. You can use this terminal to directly contact the Syndicate - just use the program \
	labelled \"fieldreport\" and they might be able to give you extra help if you've done well (i.e. done what they've asked you to) plus some extra assignments. This can only be done every \
	once in a while for security reasons, since it gives out a pretty powerful energy pulse and it might be traced. Oh, and be trigger-happy with the self-destruct function. Think that sensitive \
	data might be compromised? Boom. In maintenance and there just happens to be a high-value target on the other side of the wall? Up in smoke. These things are just crazy-modified TL bricks, \
	so it doesn't cost us a single credit. It's actually advised to blow them up rather than leave them behind since it just causes more damage that needs to be fixed manually.\n\n\
	\
	And that's about it. Don't get yourself shot."
	parent_terminal.print_message(orientation_text, "[parent_terminal] briefly displays a sun rising over a factory before loading")


//Self-explanatory
/datum/terminal_command/shutdown
	id = "shutdown"
	desc = "Shuts down the terminal."


/datum/terminal_command/shutdown/execute()
	if(!check_command())
		return 0
	parent_terminal.update_power(0)
	parent_terminal.owner << "<span class='notice'>You turn off [parent_terminal].</span>"
	return 1



//Simple IM
/datum/terminal_command/mail
	id = "mail"
	desc = "Allows simple text messages to be sent directly to other terminals."
	requires_network_access = 1
	var/list/inbox = list()


/datum/terminal_command/mail/execute()
	if(!check_command())
		return 0
	var/function = alert(parent_terminal.owner, "View inbox or send mail?", "Mail", "View", "Compose", "Cancel")
	if(!parent_terminal.has_owner())
		return 0
	switch(function)
		if("View")
			var/text = "\n<b>Your inbox:</b>"
			for(var/T in inbox)
				if(!T)
					parent_terminal.print_message("You have no mail.")
					return 1
				text += "\n[T]"
			parent_terminal.print_message(text)
			return 1
		if("Compose")
			var/message_to_send = stripped_input(parent_terminal.owner, "Enter the message to send", "Messaging")
			if(!message_to_send || !parent_terminal.owner)
				return 0
			var/recipient = stripped_input(parent_terminal.owner, "Enter the receiving terminal's ID.", "Messaging")
			if(!recipient || !parent_terminal.owner)
				return 0
			if(parent_terminal.send_message(message_to_send, recipient))
				parent_terminal.print_message("Message sent to terminal [recipient]!")
				return 1
			parent_terminal.print_message("Sending failed - no terminal with ID, or the terminal with that ID is missing net access or software.")
			return 0
		if("Cancel")
			return 0
	return 1


//Displays all terminals that are connected to the network as well as information about them
/datum/terminal_command/list
	id = "list"
	desc = "Displays the ID and location of all terminals connected to the network."
	requires_network_access = 1


/datum/terminal_command/list/execute()
	if(!check_command())
		return 0
	var/output = "\n<b>Terminals connected to network:</b>"

	var/list/terminals_to_list = terminals - parent_terminal.terminal_id
	if(!terminals_to_list.len)
		parent_terminal.print_message("No other terminals connected to network.")
		return 0
	for(var/tid in terminals_to_list)
		var/obj/machinery/terminal/T = terminals[tid]
		if(T && T.net_access)
			output += "\nTerminal [T.terminal_id], located at [get_area(T)]"
	parent_terminal.print_message(output)



//Locates and purges viruses
/datum/terminal_command/antivirus
	id = "antivirus"
	desc = "Searches for and purges malicious software."


/datum/terminal_command/antivirus/execute()
	if(!check_command())
		return 0
	var/function = alert(parent_terminal.owner, "Scan system or purge found viruses?", "Antivirus", "Scan", "Purge", "Cancel")
	if(!parent_terminal.has_owner())
		return 0
	switch(function)
		if("Scan")
			parent_terminal.print_message("Scanning system, please wait...")
			if(!do_after(parent_terminal.owner, 100, target = parent_terminal))
				return 0
			var/text = "\n<b>Results:</b>"

			for(var/vid in parent_terminal.loaded_commands)
				var/datum/terminal_command/virus/V = parent_terminal.loaded_commands[vid]
				if(istype(V))
					if(!V.veiled)
						V.revealed = 1
						var/severity_text = ""
						switch(V.severity)
							if(-INFINITY to VIRUS_HARMLESS)
								severity_text = "<span class='centcomradio'><i>Harmless</i></span>"
							if(VIRUS_MINOR)
								severity_text = "<span class='suppradio'><i>Minor</i></span>"
							if(VIRUS_THREAT)
								severity_text = "<span class='comradio'><i>Threat</i></span>"
							if(VIRUS_DANGEROUS)
								severity_text = "<span class='engradio'><i>Dangerous</i></span>"
							if(VIRUS_SYNDICATE)
								severity_text = "<span class='boldannounce'><i>CRITICAL</i></span>"
						text += "\n<span class='warning'><b>[V.id]</b></span> - Severity: [severity_text] - [V.desc] - Weaknesses: [V.recommended_action]"
			parent_terminal.print_message(text)
			return 1

		if("Purge")
			parent_terminal.print_message("Initiating cleansing of malicious software...")
			for(var/cid in parent_terminal.loaded_commands)
				var/datum/terminal_command/virus/V = parent_terminal.loaded_commands[cid]
				if(istype(V) && V.revealed && !V.resilient)
					parent_terminal.cleanse_virus(V.id)
			parent_terminal.print_message("<span class='notice'>Cleansing complete!</span>")
			return 1

		if("Cancel")
			return 0
	return 1