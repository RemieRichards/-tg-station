//Infects a large amount of terminals with the spambot virus
/datum/round_event_control/chain_mail
	name = "Chain Mail"
	typepath = /datum/round_event/chain_mail
	max_occurrences = 3
	weight = 15

/datum/round_event/chain_mail
	startWhen = 10
	announceWhen = 25

/datum/round_event/chain_mail/start()
	for(var/obj/machinery/terminal/T in terminals)
	for(var/tid in terminals)
		var/obj/machinery/terminal/T = terminals[tid]
		if(T && T.net_access && prob(25))
			T.add_command("GreatDeals")

/datum/round_event/chain_mail/announce()
	priority_announce("Rival corporations have begun an aggressive marketing campaign. Please run viral scans on all terminals connected to the network.", "Great Deals", 'sound/AI/attention.ogg')
