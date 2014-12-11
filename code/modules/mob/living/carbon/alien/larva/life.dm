//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/larva
	var/temperature_alert = 0


/mob/living/carbon/alien/larva/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(notransform)
		return

	..()

	if(stat != DEAD)
		// GROWTH
		if(amount_grown < max_grown)
			amount_grown++

	//Redraw mob icons
	update_icons()

	//Move delay
	if(move_delay_add > 0)
		move_delay_add = max(0, move_delay_add - rand(1, 2))


/mob/living/carbon/alien/larva/handle_random_events()
	return

