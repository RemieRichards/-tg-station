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
	var/processes = FALSE //Do we execute_process() when our terminal process()es?


/datum/terminal_command/proc/check_command()
	if(!parent_terminal)
		return 0
	if(!parent_terminal.has_owner())
		return 0
	if(requires_network_access && !parent_terminal.net_access)
		parent_terminal.print_message("This command requires network access. Unable to continue.")
		return 0
	if(requires_cooldown && cooldown)
		parent_terminal.print_message("This command is still rebooting. Unable to continue.")
		return 0
	return 1


/datum/terminal_command/proc/execute() //When making a subtype, add a check_command() check.


/datum/terminal_command/proc/execute_process() //If we process, what do we do on the terminal's process()?, defaults to execute() (Needs a check_command() if you don't use execute() here)
	execute()


/datum/terminal_command/proc/run_cooldown()
	if(!requires_cooldown || cooldown)
		return 0
	cooldown = 1
	sleep(cooldown_time)
	if(cooldown)
		if(parent_terminal)
			parent_terminal.print_message("Command \"[id]\" is now ready to be used again.")
			playsound(get_turf(parent_terminal), 'sound/machines/chime.ogg', 50, 1)
		cooldown = 0





