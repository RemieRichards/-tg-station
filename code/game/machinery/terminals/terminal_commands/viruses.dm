
/*
Viruses are special types of terminal commands meant for the express purpose of damaging a terminal.
They are typically undetectable and will continue to affect the terminal unless removed.
There are several methods of removing a virus - an antivirus program can do it, as does reconstructing the terminal (at the cost of all data being lost).
In addition, most viruses have a weakness that allows them to be purged, usually involving whatever they affect.
*/

/datum/terminal_command/virus
	id = "base virus"
	processes = TRUE //most viruses execute_process
	var/recommended_action = "Running the program directly will purge it." //The way a virus can be removed from a terminal. Generally a list of weaknesses.
	var/revealed = 0 //If the virus has been outed and can be removed from the system
	var/veiled = 0 //If the virus cannot be detected by antivirus
	var/resilient = 0 //If the virus cannot be removed by antivirus
	var/severity = 0 //Severity ranges from annoyance to crippling


//Hijacks the mail function, causing it to randomly send spam to other terminals.
/datum/terminal_command/virus/spambot
	id = "GreatDeals"
	desc = "Forces the terminal to send out mail to other connected terminals."
	recommended_action = "Changing the terminal's ID will break the virus."
	severity = VIRUS_HARMLESS


/datum/terminal_command/virus/spambot/execute_process()
	if(!check_command())
		return 0
	for(var/tid in terminals - parent_terminal.terminal_id)
		var/obj/machinery/terminal/T = terminals[tid]
		if(T)
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
				parent_terminal.send_message(pick(flavor_text), tid, 1)


//Prevents all messages from successfully sending or being received. Small chance of being detected when booting up the mail program.
/datum/terminal_command/virus/mail_inhibitor
	id = "CourierCrusher"
	desc = "Inhibits the functionality of messaging."
	recommended_action = "If a message's recipient is the same as its sender, the program will self-terminate."
	severity = VIRUS_MINOR


//Silly request from KorPhaeron. Does nothing, but if a virologist attempts to use the terminal, it self-destructs!
/datum/terminal_command/virus/remove_virology
	id = "RemoveViro"
	desc = "REMOVE VIROLOGY remove virology"
	recommended_action = "A virologist must turn on the terminal."
	resilient = 1
	severity = VIRUS_SYNDICATE //So it can't be infected as a result of random chance


/datum/terminal_command/virus/power_overload //Overloads the target terminal with a massive jolt of energy upon sending, causing heavy power drain and imminent explosion
	id = "PowerOverwhelming"
	desc = "Instantly forces a terminal to draw a huge amount of power from the network, causing it to explode. Excess power is drawn from the Exolitic crystal within the sender."
	resilient = 1
	veiled = 1
	severity = VIRUS_SYNDICATE


/datum/terminal_command/virus/power_overload/execute_process()
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
