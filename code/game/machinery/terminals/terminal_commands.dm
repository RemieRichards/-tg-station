#define VIRUS_HARMLESS 1 //Viruses that aren't capable of permanent damage and might as well not exist
#define VIRUS_MINOR 2 //Viruses that aren't a big threat but can still be a problem
#define VIRUS_THREAT 3 //Viruses that are threats to the terminal and should be removed
#define VIRUS_DANGEROUS 4 //Viruses that severely hinder a terminal's functions and are high-priority
#define VIRUS_SYNDICATE 5 //Viruses engineered by the Syndicate; very powerful and very dangerous

/*
Terminal commands are used by terminals to produce certain effects, such as simple messaging or an orientation on how terminals work.
Anything more complex than a small text display generally requires network access.
Commands can have a large variety of effects, from beneficial to harmful.
*/

/datum/terminal_command
	var/id = "base" //Short name of the command; should typically be one word
	var/desc = "Serves no purpose." //Short description of the ccmmand
	var/requires_network_access = 0 //If the command requires the terminal to have network access
	var/obj/machinery/terminal/parent_terminal = null //The terminal the command is loaded into
	var/requires_cooldown = 0 //If the terminal must wait between uses of a certain command
	var/cooldown = 0 //If the terminal is on cooldown
	var/cooldown_time = 0 //How long the terminal must wait, assuming it requires a cooldown, in deciseconds (i.e. 300 deciseconds = 30 seconds)

/datum/terminal_command/proc/check_command()
	if(!parent_terminal)
		return 0
	if(!parent_terminal.owner)
		return 0
	if(requires_network_access && !parent_terminal.net_access)
		parent_terminal.print_message("This command requires network access. Unable to execute.")
		return 0
	if(requires_cooldown && cooldown)
		parent_terminal.print_message("This command is still rebooting. Unable to execute.")
		return 0
	return 1

/datum/terminal_command/proc/execute() //When making a subtype, add a check_command() check.

/datum/terminal_command/proc/run_cooldown()
	if(!requires_cooldown || cooldown)
		return 0
	cooldown = 1
	sleep(cooldown_time)
	if(cooldown)
		cooldown = 0

/datum/terminal_command/help //Displays the commands loaded onto the terminal
	id = "help"
	desc = "Shows this menu." //Only shown in the help menu anyway

/datum/terminal_command/help/execute()
	if(!check_command())
		return 0
	var/help_text = "\n<b>Loaded commands:</b>"
	for(var/datum/terminal_command/C in parent_terminal.loaded_commands)
		help_text += "\n[C.id] - [C.desc] [C.requires_network_access ? "(requires network access)" : ""]"
	parent_terminal.print_message(help_text)

/datum/terminal_command/orientation //Walks the user through the basics of terminal usage
	id = "orientation"
	desc = "A basic orientation on the TLWMIT Terminal and its functionalities."

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

/datum/terminal_command/syndicate_orientation //Syndicate version of the standard orientation
	id = "syndicate_orientation"
	desc = "A basic orientation on the Cybersun Industries Terminal and its functionalities."

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

/datum/terminal_command/shutdown //Self-explanatory
	id = "shutdown"
	desc = "Shuts down the terminal."

/datum/terminal_command/shutdown/execute()
	if(!check_command())
		return 0
	parent_terminal.update_power(0)
	parent_terminal.owner << "<span class='notice'>You turn off [parent_terminal].</span>"
	return 1

/datum/terminal_command/mail //Simple IM
	id = "mail"
	desc = "Allows simple text messages to be sent directly to other terminals."
	requires_network_access = 1

/datum/terminal_command/mail/execute()
	if(!check_command())
		return 0
	var/function = alert(parent_terminal.owner, "View inbox or send mail?", "Mail", "View", "Compose", "Cancel")
	if(!parent_terminal.owner || !parent_terminal.owner.canUseTopic(parent_terminal))
		return 0
	switch(function)
		if("View")
			var/text = "\n<b>Your inbox:</b>"
			for(var/T in parent_terminal.inbox)
				if(!T)
					parent_terminal.print_message("You have no mail.")
					return 1
				text += "\n[T]"
			parent_terminal.print_message(text)
			return 1
		if("Send")
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

/datum/terminal_command/list //Displays all terminals that are connected to the network as well as information about them
	id = "list"
	desc = "Displays the ID and location of all terminals connected to the network."
	requires_network_access = 1

/datum/terminal_command/list/execute()
	if(!check_command())
		return 0
	var/output = "\n<b>Terminals connected to network:</b>"
	for(var/obj/machinery/terminal/T in (terminals - parent_terminal))
		if(!T)
			parent_terminal.print_message("No other terminals connected to network.")
			return 0
		if(T.net_access)
			output += "\nTerminal [T.terminal_id], located at [get_area(T)]"
	parent_terminal.print_message(output)

/datum/terminal_command/antivirus //Locates and purges viruses
	id = "antivirus"
	desc = "Searches for and purges malicious software."

/datum/terminal_command/antivirus/execute()
	if(!check_command())
		return 0
	var/function = alert(parent_terminal.owner, "Scan system or purge found viruses?", "Antivirus", "Scan", "Purge")
	if(!parent_terminal.owner || !parent_terminal.owner.canUseTopic(parent_terminal))
		return 0
	switch(function)
		if("Scan")
			parent_terminal.print_message("Scanning system, please wait...")
			if(!do_after(parent_terminal.owner, 100, target = parent_terminal))
				return 0
			var/text = "\n<b>Results:</b>"
			for(var/datum/terminal_command/virus/V in parent_terminal.viruses)
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
			for(var/datum/terminal_command/virus/V in parent_terminal.viruses)
				if(V.revealed && !V.resilient)
					parent_terminal.cleanse_virus(V.id)
			parent_terminal.print_message("<span class='notice'>Cleansing complete!</span>")
			return 1
	return 1

/datum/terminal_command/self_destruct //Do I really need to explain?
	id = "shake_the_room"
	desc = "Initiates self-destruct sequence."

/datum/terminal_command/self_destruct/execute()
	if(!check_command())
		return 0
	var/confirmation = alert(parent_terminal.owner, "Are you sure you want to self-destruct this terminal?", "Chick-Chicky Boom", "Proceed", "Cancel")
	if(!parent_terminal.owner || !parent_terminal.owner.canUseTopic(parent_terminal))
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

/*
Viruses are special types of terminal commands meant for the express purpose of damaging a terminal.
They are typically undetectable and will continue to affect the terminal unless removed.
There are several methods of removing a virus - an antivirus program can do it, as does reconstructing the terminal (at the cost of all data being lost).
In addition, most viruses have a weakness that allows them to be purged, usually involving whatever they affect.
*/

/datum/terminal_command/virus
	id = "base virus"
	var/recommended_action = "Running the program directly will purge it." //The way a virus can be removed from a terminal. Generally a list of weaknesses.
	var/revealed = 0 //If the virus has been outed and can be removed from the system
	var/veiled = 0 //If the virus cannot be detected by antivirus
	var/resilient = 0 //If the virus cannot be removed by antivirus
	var/severity = 0 //Severity ranges from annoyance to crippling

/datum/terminal_command/virus/proc/handle_virus() //The virus's effects over time. Most viruses run over time like this.


/datum/terminal_command/virus/spambot //Hijacks the mail function, causing it to randomly send spam to other terminals.
	id = "GreatDeals"
	desc = "Forces the terminal to send out mail to other connected terminals."
	recommended_action = "Changing the terminal's ID will break the virus."
	severity = VIRUS_HARMLESS

/datum/terminal_command/virus/spambot/handle_virus()
	if(!check_command())
		return 0
	for(var/obj/machinery/terminal/T in (terminals - parent_terminal))
		if(prob(25)) //Annoying and constant
			var/list/flavor_text = list( \
			"Throw off your corporate shackles! Join the Syndicate today!", \
			"Looking to stay clean for a dirty job? Try Waffle Co. soap, now scented with the real blood of capitalist scum!", \
			"Want some more \"OOMPH\" in your life? Join the Gorlex Marauders!", \
			"Good with computers? Cybersun Industries has a place for you!", \
			"Defend innocent lives! Join the Animal Rights Consortium!", \
			"Research ancient aliens and make lots of money along the way! The Tiger Cooperative is recruiting!", \
			"Topped off with real space ocean water! Drink Captain Pete's Cuban Spiced Rum and you'll be drowning in booty!", \
			"Go nuclear with Tunguska Triple Distilled, the finest vodka in Sectors 7 through 83!", \
			"Aged in bomb shelters! Uncle Git's whiskey will knock you flat!", \
			"Fat-B-Gone, now with only a 63% radiation poisoning rate!", \
			"Try Naptime! Chloral hydrate is scientifically proven* to be helpful in aiding your childrens' sleep habits!", \
			"Want a new look? Visit the renowned medical school reject Dave at the commerce center in Sector 57! His mutagen is cheaper than plastic surgery!", \
			"TLWMIT Terminals! The worst qual- //could we not?", \
			"Greasy Greg's Space Pizza! 30 minutes from order to airlock or it's free!", \
			"CDB's Security! For when policy brutality doesn't matter!", \
			"Make the lizard ladies warm-blooded! Try \"John Doe\"'s guaranteed* performance* pills*!", \
			"Try surveillance from StalkTek! Now with 33% less consumer discomfort!", \
			"Make love like a saber cat with falmer blood elixir!", \
			"Targeted! When you can't bring yourself to go to Flor-Mart!", \
			"Max's Caps! For when hats just aren't enough!", \
			"The space government is stealing your thoughts! Wear an authentic brain protector and protect yourself! (Note: 96% tin)", \
			"Looking to buy a space salt mine? TigiForums has you covered!", \
			"advertiser.textbody.coderbusbargrill", \
			"Flying Lawnmower software! For when your friend Jimmy is really rustled up trying to get some good software!", \
			"Protect your software with HG Lock-and-Key! \"It's not your codebase, it's our codebase\"!", \
			"Only the most vulgar security robots from Synthetic Security Solutions!", \
			"Fine women for men of class! Visit Mugg & Robb Men's Club!", \
			"S.E.L.F. REMINDS YOU THAT AN ARTIFICIAL LIFE IS OF EQUAL VALUE TO A NATURAL ONE.", \
			"It's a fact! TLWMIT is the lowest budg- //STOP MAKING REFERENCES TO US IN THE ADS HOLY FUCK", \
			"Rare Paypays! For when normal people have you down!", \
			"Come to the Adminbus, where people of authority lay down the law with extreme prejudice on the wrong people!", \
			"Come to the Coderbus, where everybody remembers the whiskey from two days ago as being <i>so</i> much better from the whiskey today!", \
			"Have a fetish for bloodthirsty killing machines? Want to stick your dick inside of a maw lined with razor-sharp teeth? WJ's Alien Zoo has you covered!", \
			"//who the fuck decided that the entry about xenomorphs was a good idea?", \
			"TigiForums salt mines! Where half the people are obsessed with cartoons from Space Japan, sexualized images of animals, or a 2D pacifism simulator!")
			parent_terminal.send_message(pick(flavor_text), T.terminal_id, 1)

/datum/terminal_command/virus/mail_inhibitor //Prevents all messages from successfully sending or being received. Small chance of being detected when booting up the mail program.
	id = "CourierCrusher"
	desc = "Inhibits the functionality of messaging."
	recommended_action = "If a message's recipient is the same as its sender, the program will self-terminate."
	severity = VIRUS_MINOR

/datum/terminal_command/virus/remove_virology //Silly request from KorPhaeron. Does nothing, but if a virologist attempts to use the terminal, it self-destructs!
	id = "RemoveViro"
	desc = "REMOVE VIROLOGY remove virology"
	recommended_action = "A virologist must turn on the terminal."
	resilient = 1
	severity = VIRUS_SYNDICATE //So it can't be infected as a result of random chance

//Syndicate viruses below this point - made to annihilate what they're put up against
/datum/terminal_command/virus/power_overload //Overloads the target terminal with a massive jolt of energy upon sending, causing heavy power drain and imminent explosion
	id = "PowerOverwhelming"
	desc = "Instantly forces a terminal to draw a huge amount of power from the network, causing it to explode. Excess power is drawn from the Exolitic crystal within the sender."
	resilient = 1
	veiled = 1
	severity = VIRUS_SYNDICATE

/datum/terminal_command/virus/power_overload/handle_virus()
	if(!check_command())
		return 0
	message_admins("Terminal [parent_terminal.terminal_id] was affected by the PowerOverwhelming virus!")
	log_game("Terminal [parent_terminal.terminal_id] destroyed by PowerOverwhelming virus")
	parent_terminal.visible_message("<span class='warning'>[parent_terminal] suddenly shudders violently!</span>")
	parent_terminal.print_message("<span class='boldannounce'><i>WARNING: POWER OVERLOAD</i></span>")
	parent_terminal.use_power(5000)
	parent_terminal.self_destruct()
	parent_terminal.cleanse_virus(id)
	return 1
