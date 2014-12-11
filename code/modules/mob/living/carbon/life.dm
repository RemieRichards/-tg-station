
/mob/living/carbon/Life()
	set invisibility = 0
	set background = BACKGROUND_ENABLED

	if(notranform)
		return

	..()

	//At the top as the below procs change these.
	blindend = null
	fire_alert = 0
	tinttotal = tintcheck()

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	if(stat != DEAD)
		//Breathing, if applicable
		handle_breathing()

		//Changeling, if applicable
		handle_changeling()

		//Mutations and Radiation
		handle_mutations_and_radiation()

		//Chemicals/Reagents
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//Vomiting, Monkey emotes, etc.
		handle_random_events()

	//Environmental factors
	handle_environment(environment)

	//Burn baby burn
	handle_fire()

	//Things in the mob's stomach
	handle_stomach()

	//Health, Death etc.
	handle_regular_status_updates()

	//Can the mob move
	update_canmove()

	//Update the mob HUD
	if(client)
		handle_regular_hud_updates()

	//Process grab objects
	for(var/obj/item/weapon/grab/G in src)
		G.process()


///////////////
// BREATHING //
///////////////

//Start of a breath chain, calls breathe()
/mob/living/carbon/proc/handle_breathing()

	if(air_master.current_cylce%4==2 || failed_last_breath)
		breathe() //Breathe per 4 ticks, unless suffocating
	else
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src,0)

//Second link in a breath chain, calls check_breath()
/mob/living/carbon/proc/breathe()
	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return

	var/datum/gas_mixture/environment
	if(loc)
		environment = loc.return_air()

	var/datum/gas_mixture/breath

	if(health <= config.health_threshold_crit)
		losebreath++

	//Suffocate
	if(losebreath > 0)
		losebreath--
		if(prob(10))
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/loc_as_obj = loc
			loc_as_obj.handle_internal_lifeform(src,0)
	else
		//Breathe from internal
		breath = get_breath_from_internal(BREATH_VOLUME)

		if(!breath)

			if(isobj(loc)) //Breathe from loc as object
				var/obj/loc_as_obj = loc
				breath = loc_as_obj.handle_internal_lifeform(src, BREATH_VOLUME)

			else if(isturf(loc)) //Breathe from loc as turf
				var/breath_moles = 0
				if(environment)
					breath_moles = environment.total_moles()*BREATH_PERCENTAGE

				breath = loc.remove_air(breath_moles)


				//Gas masks
				var/block = 0

				if(wear_mask)
					if(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
				if(glasses)
					if(glasses.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
				if(head)
					if(head.flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1

				//Harmful gasses
				if(!block)
					for(var/obj/effect/effect/chem_smoke/smoke in view(1,src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src,INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10)
							break

		else //Breathe from loc as obj again
			if(istype(loc, /obj/))
				var/obj/loc_as_obj = loc
				loc_as_obj.handle_internal_lifeform(src,0)

	check_breath(breath)

	if(breath)
		loc.assume_air(breath)

//Third link in a breath chain, calls handle_temperature()
/mob/living/carbon/proc/check_breath(datum/gas_mixture/breath)
	if((status_flags & GODMODE))
		return

	//CRIT
	if(!breath || (breath.total_moles() == 0))
		if(reagents.has_reagent("inaprovaline"))
			return
		if(health >= config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_last_breath = 1
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			failed_last_breath = 1

		oxygen_alert = max(oxygen_alert, 1)

		return 0

	var/safe_oxy_min = 16
	var/safe_co2_max = 10
	var/safe_tox_max = 0.005
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/oxygen_used = 0
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/O2_partialpressure = (breath.oxygen/breath.total_moles())*breath_pressure
	var/Toxins_partialpressure = (breath.toxins/breath.total_moles())*breath_pressure
	var/CO2_partialpressure = (breath.carbon_dioxide/breath.total_moles())*breath_pressure


	//OXYGEN
	if(O2_partialpressure < safe_oxy_min) //Not enough oxygen
		if(health <= config.health_threshold_crit)
			if(prob(20))
				spawn(0) emote("gasp")
			if(O2_partialpressure > 0)
				var/ration = safe_oxy_min/O2_partialpressure
				adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS))
				failed_last_breath = 1
				oxygen_used = breath.oxygen*ration/6
			else
				adjustOxyLoss(HUMAN_MAX_OXYLOSS)
				failed_last_breath = 1
			oxygen_alert = max(oxygen_alert, 1)

	else //Enough oxygen
		failed_last_breath = 0
		adjustOxyLoss(-5)
		oxygen_used = breath.oxygen/6
		oxygen_alert = 0

	breath.oxygen -= oxygen_used
	breath.carbon_dioxide += oxygen_used

	//CARBON DIOXIDE
	if(CO2_partialpressure > safe_co2_max)
		if(!co2overloadtime)
			co2overloadtime = world.time
		else if(world.time - co2overloadtime > 120)
			Paralyse(3)
			adjustOxyLoss(3)
			if(world.time - co2overloadtime > 300)
				adjustOxyLoss(8)
		if(prob(20))
			spawn(0) emote("cough")

	else
		co2overloadtime = 0

	//TOXINS/PLASMA
	if(Toxins_partialpressure > safe_tox_max)
		var/ratio = (breath.toxins/safe_toxins_max) * 10
		if(reagents)
			reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
		toxins_alert = max(toxins_alert, 1)
	else
		toxins_alert = 0

	//TRACE GASES
	if(breath.trace_gases.len)
		for(var/datum/gas/sleeping_agent/SA in breath.trace_gases)
			var/SA_partialpressure = (SA.moles/breath.total_moles())*breath_pressure
			if(SA_partialpressure > SA_para_min)
				Paralyse(3)
				if(SA_partialpressure > SA_sleep_min)
					sleeping = max(sleeping+2, 10)
			else if(SA_partialpressure > 0.01)
				if(prob(20))
					spawn(0) emote(pick("giggle","laugh"))

	//BREATH TEMPERATURE
	handle_temperature(breath)

	return 1

//Fourth and final link in a breath chain
/mob/living/carbon/proc/handle_temperature(datum/gas_mixture/breath)
	if((abs(310.15 - breath.temperature) > 50) && !(COLD_RESISTANCE in mutations))
		//FLUFF
		if(breath.temperature < 260.15)
			if(prob(20))
				src << "<span class='danger'>You feel your face freezing and an icicle forming in your lungs!</span>"
		else if(breath.temperature > 360.15)
			if(prob(20))
				H << "<span class='danger'>You feel your face burning and a searing heat in your lungs!</span>"

		//COLD
		if(!(COLD_RESISTANCE in mutations))
			switch(breath.temperature)
				if(-INFINITY to 120)
					apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head")
					fire_alert = max(fire_alert, 1)
				if(120 to 200)
					apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head")
					fire_alert = max(fire_alert, 1)
				if(200 to 260)
					apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head")
					fire_alert = max(fire_alert, 1)

		//HEAT
		switch(breath.temperature)
			if(360 to 400)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head")
				fire_alert = max(fire_alert, 2)
			if(400 to 1000)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head")
				fire_alert = max(fire_alert, 2)
			if(1000 to INFINITY)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head")
				fire_alert = max(fire_alert, 2)

	return

//Proc for breathing from internals
/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return

////////////////
// CHANGELING //
////////////////

/mob/living/carbon/proc/handle_changeling()
	if(mind && mind.changeling)
		mind.changeling.regenerate()
		hud_used.lingchemdisplay.invisibility = 0
		hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font color='#dd66dd'>[src.mind.changeling.chem_charges]</font></div>"
	else
		hud_used.lingchemdisplay.invisibility = 101

/////////////////////////////
// MUTATIONS AND RADIATION //
/////////////////////////////

/mob/living/carbon/proc/handle_mutations_and_radiation()
	if(getFieLoss())
		if((COLD_RESISTANCE in mutations) || (prob(1)))
			heal_organ_damage(0,1)

	if(radiation)
		radiation = Clamp(radiation, 0, 100)

		if(radiation > 100)
			Weaken(10)
			H << "<span class='danger'>You feel weak.</span>"
			emote("collapse")

		if(radiation)
			switch(radiation)
				if(0 to 50)
					radiation--
					if(prob(25))
						adjustToxLoss(1)
				if(50 to 75)
					radiation -= 2
					adjustToxLoss(1)
					if(prob(5))
						radiation -= 5
						Weaken(3)
						src << "<span class='danger'>You feel weak.</span>"
						emote("collapse")
			updatehealth()


/mob/living/carbon/human/handle_mutations_and_radiation()
	..()

	switch(radiation)
		if(50 to 75)
			if(prob(15))
				if(!(hair_style == "Shaved") || !(hair_style == "Bald"))
					src << "<span class='danger'>Your hair starts to fall out in clumps...</span>"
					spawn(50)
						facial_hair_style = "Shaved"
						hair_style = "Bald"
						update_hair()
		if(75 to 100)
			radiation -= 3
			adjustToxLoss(3)
			if(prob(1))
				src << "<span class='danger'>You mutate!</span>"
				randmutb(src)
				domutcheck(src,null)
				emote("gasp")
	updatehealth()


	if((HULK in mutations) && health <= 25)
		mutations.Remove(HULK)
		update_mutations()
		src << "<span class='danger'>You suddenly feel very weak.</span>"
		Weaken(3)
		emote("collapse")

///////////////////////
// CHEMICALS IN BODY //
///////////////////////

/mob/living/carbon/proc/handle_chemicals_in_body()
	if(reagents)
		reagents.metabolize(src)

	if(drowsyness)
		drowsyness--
		eye_blurry = max(2, eye_blurry)
		if(prob(5))
			sleeping++
			Paralyse(5)

	confused = max(0, confused - 1)

	if(resting)
		dizziness = max(0, dizziness - 15)
		jitteriness = max(0, jitteriness - 15)
	else
		dizziness = max(0, dizziness - 3)
		jitteriness = max(0, jitteriness - 3)

	updatehealth()


/mob/living/carbon/human/handle_chemicals_in_body()
	..()


	//FAT
	if(FAT in mutations)
		if(overeatduration < 100)
			H << "<span class='notice'>You feel fit again!</span>"
			mutations -= FAT
			update_inv_w_uniform(0)
			update_inv_wear_suit()
	else
		if(overeatduration > 500)
			H << "<span class='danger'>You suddenly feel blubbery!</span>"
			mutations |= FAT
			update_inv_uniform(0)
			update_inv_wear_suit()


	//NUTRITION
	if(nutrition > 0 && stat != DEAD)
		nutrition = max(0, nutrition - HUNGER_FACTOR)

	if(nutrition > 450)
		if(overeatduration < 600)
			overeatduration++
	else
		if(overeatduration > 1)
			overeatduration -= 2

//////////////////
// DISABILITIES //
//////////////////

/mob/living/carbon/proc/handle_disabilities()
	if(disabilites & EPILEPSY)
		if((prob(1) && paralysis < 10))
			src << "<span class='danger'>You have a seizure!</span>"
			Paralyse(10)
	if(disabilities & COUGHING)
		if((prob(5) && paralysis <= 1))
			drop_item()
			spawn(0)
				emote("cough")
				return
	if(disabilities & TOURETTES)
		if((prob(10) && paralysis <= 1))
			Stun(10)
			spawn(0)
				emote("twitch")
				return
	if(disabilities & NERVOUS)
		if(prob(10))
			stuttering = max(10, stuttering)


/mob/living/carbon/human/handle_disabilities()
	..()

	if (disabilities & TOURETTES)
		if ((prob(10) && paralysis <= 1))
			Stun(10)
			switch(rand(1, 3))
				if(1)
					emote("twitch")
				if(2 to 3)
					say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
			var/x_offset = pixel_x + rand(-2,2) //Should probably be moved into the twitch emote at some point.
			var/y_offset = pixel_y + rand(-1,1)
			animate(src, pixel_x = pixel_x + x_offset, pixel_y = pixel_y + y_offset, time = 1)
			animate(pixel_x = initial(pixel_x) , pixel_y = initial(pixel_y), time = 1)

	if (getBrainLoss() >= 60 && stat != 2)
		if (prob(3))
			switch(pick(1,2,3))
				if(1)
					say(pick("IM A PONY NEEEEEEIIIIIIIIIGH", "without oxigen blob don't evoluate?", "CAPTAINS A COMDOM", "[pick("", "that faggot traitor")] [pick("joerge", "george", "gorge", "gdoruge")] [pick("mellens", "melons", "mwrlins")] is grifing me HAL;P!!!", "can u give me [pick("telikesis","halk","eppilapse")]?", "THe saiyans screwed", "Bi is THE BEST OF BOTH WORLDS>", "I WANNA PET TEH monkeyS", "stop grifing me!!!!", "SOTP IT#"))
				if(2)
					say(pick("FUS RO DAH","fucking 4rries!", "stat me", ">my face", "roll it easy!", "waaaaaagh!!!", "red wonz go fasta", "FOR TEH EMPRAH", "lol2cat", "dem dwarfs man, dem dwarfs", "SPESS MAHREENS", "hwee did eet fhor khayosss", "lifelike texture ;_;", "luv can bloooom", "PACKETS!!!"))
				if(3)
					emote("drool")

///////////////////
// RANDOM EVENTS //
///////////////////

/mob/living/carbon/proc/handle_random_events()
	if(!stat)
		if(getToxLoss() >= 45)
			lastpuke++
			if(lastpuke >= 25)
				Stun(5)
				visible_message("<span class='danger'>[src] throws up!</span>",\
				"<span class='userdanger'>[src] throws up!</span>")
				var/turf/location = get_turf(src)
				playsound(location, 'sound/effects/splat.ogg', 50, 1)
				location.add_vomit_floor(src, 1)
				nutrition = max(nutrition-20,0)
				adjustToxLoss(-3)
				lastpuke = 0

/////////////////
// ENVIRONMENT //
/////////////////

/mob/living/carbon/proc/handle_environment(datum/gas_mixture/environment)
	return

//////////
// FIRE //
//////////

//carbon handle_fire() is the same as /living/handle_fire()

/////////////
// STOMACH //
/////////////

/mob/living/carbon/proc/handle_stomach()
	spawn(0)
		for(var/mob/living/M in stomach_contents)
			if(M.loc != src)
				stomach_contents.Remove(M)
				continue
			if(istype(M, /mob/living/carbon) && stat != DEAD)
				if(M.stat == DEAD)
					M.death(1)
					stomach_contents.Remove(M)
					qdel(M)
					continue
				if(air_master.current_cycle%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(5)
					nutrition += 10

////////////////////////////
// REGULAR STATUS UPDATES //
////////////////////////////

/mob/living/carbon/proc/handle_regular_status_updates()
	if(stat == DEAD)
		blined = 1
		silent = 0
	else
		updatehealth()
		if(health <= config.health_threshold_dead || !getorgan(/obj/item/organ/brain))
			death()
			blinded = 1
			silent = 0
			return 1

		if((getOxyLoss() > 50) || (config.health_threshold_cirt >= health))
			Paralyse(3)

		//HALLUCINATION
		if(hallucination)
			if(hallucination >= 20)
				if(prob(3))
					fake_attack(src)
				if(!handling_hal)
					spawn handle_halucinations()

			hallucination = max(hallucination-2, 0)
		else
			for(var/atom/A in hallucinations)
				qdel(A)

		//CONSCIOUSNESS
		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			handle_dreams()
			adjustStaminaLoss(-10)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if(prob(10) && health && !hal_crit)
				spawn(0)
					emote("snore")
		else
			stat = CONSCIOUS

		//DISABILITIES

		//Not a typo, "sdisabilities" is a totally different list of disabilities, for some reason
		if(sdisabilities & BLIND) //disabled-blind, doesn't heal
			blinded = 1
		else if(eye_blind) //blindness, heals slowly
			eye_blind = max(eye_blind-1,0)
			blinded = 1
		else if(tinttotal >= TINT_BLIND) //covering eyes heals them faster
			eye_blurry = max(eye_blurry-3,0)
		else if (eye_blurry) //blurry eyes heal slowly
			eye_blurry = max(eye_blurry-1,0)

		if(sidisabilities & DEAF) //disabled-dead, doesn't heal
			ear_deaf = max(ear_deaf, 1)
		else if(istype(ears, /obj/item/clothing/ears/earmuffs)) //resting ears heal faster
			ear_damage = max(ear_damage-0.15,0)
			ear_deaf = max(ear_deaf-1),1)
		else if(ear_deaf) // deafness, heals slowly
			ear_deaf = max(ear_deaf-1, 0)
		else if(ear_damage < 25) //ear damage, heals slowly whilst under 25
			ear_damage = max(ear_damage-0.05, 0)

		//DIZZINESS
		if(dizziness)
			var/client/C = client
			var/pixel_x_diff = 0
			var/pixel_y_diff = 0
			var/temp
			var/saved_dizz = dizziness
			dizziness = max(dizziness-1,0)
			if(C)
				var/oldsrc = src
				var/amplitude = dizzineness*(sin(dizziness * 0.044 * world.time) + 1)/70
				src = null
				spawn(0)
					if(C)
						temp = amplitude * sin(0.008 * saved_dizz * world.time)
						pixel_x_diff += temp
						C.pixel_x += temp
						temp = amplitude * cos(0.008 * saved_dizz * world.time)
						pixel_y_diff += temp
						C.pixel_y += temp
						sleep(3)
						if(C)
							temp = amplitude * sin(0.008 * saved_dizz * world.time)
							pixel_x_diff += temp
							C.pixel_x += temp
							temp = amplitude * cos(0.008 * saved_dizz * world.time)
							pixel_y_diff += temp
							C.pixel_y += temp
						sleep(3)
						if(C)
							C.pixel_x -= pixel_x_diff
							C.pixel_y -= pixel_y_diff
				src = oldsrc

		//JITTERINESS
		if(jitteriness)
			var/amplitude = min(4, (jitteriness/100) + 1)
			var/pixel_x_diff = rand(-amplitude, amplitude)
			var/pixel_y_diff = rand(-amplitude/3, amplitude/3)

			animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff. time = 2, loop = 6)
			animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)
			floating = 0
			jitteriness = max(jitteriness-1, 0)


		//MISC
		if(stunned)
			AdjustStunned(-1)

		if(weakened)
			weakened = max(weakened-1,0)

		if(stuttering)
			stuttering = max(stuttering-1,0)

		if(silent)
			silent = max(silent-1,0)

		if(druggy)
			druggy = max(druggy-1,0)

		CheckStamina()

	return 1


/////////
// HUD //
/////////

/mob/living/carbon/proc/handle_regular_hud_updates()
	if(!client)
		return 0

	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask)
	update_action_buttons()

	if(damageoverlay.overlays)
		damageoverlay.overlays = list()

	if(stat == UNCONSCIOUS)
		if(health <= config.health_threshold_crit)
			var/image/I = image("icon"='icons/mob/screen_full.dmi',"icon_state"="passage0")
			I.blend_mode = BLEND_OVERLAY
			switch(health)
				if(-20 to -10)
					I.icon_state = "passage1"
				if(-30 to -20)
					I.icon_state = "passage2"
				if(-40 to -30)
					I.icon_state = "passage3"
				if(-50 to -40)
					I.icon_state = "passage4"
				if(-60 to -50)
					I.icon_state = "passage5"
				if(-70 to -60)
					I.icon_state = "passage6"
				if(-80 to -70)
					I.icon_state = "passage7"
				if(-90 to -80)
					I.icon_state = "passage8"
				if(-95 to -90)
					I.icon_state = "passage9"
				if(-INFINITITY to -95)
					I.icon_state = "passage10"
			damageoverlay.overlays += I
	else
		if(oxyloss)
			var/image/I = image("icon"='icons/mob/screen_full.dmi',"icon_state"="oxydamageoverlay0")
			switch(oxyloss)
				if(10 to 20)
					I.icon_state = "oxydamageoverlay1"
				if(20 to 25)
					I.icon_state = "oxydamageoverlay2"
				if(25 to 30)
					I.icon_state = "oxydamageoverlay3"
				if(30 to 35)
					I.icon_state = "oxydamageoverlay4"
				if(35 to 40)
					I.icon_state = "oxydamageoverlay5"
				if(40 to 45)
					I.icon_state = "oxydamageoverlay6"
				if(45 to INFINITY)
					I.icon_state = "oxydamageoverlay7"
			damageoverlay.overlays += I


		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0
		if(hurtdamage)
			var/image/I = image("icon"='icons/mob/screen_full.dmi',"icon_state"="brutedamageoverlay0")
			I.blend_mode = BLEND_ADD
			switch(hurtdamage)
				if(5 to 15)
					I.icon_state = "brutedamageoverlay1"
				if(15 to 30)
					I.icon_state = "brutedamageoverlay2"
				if(30 to 45)
					I.icon_state = "brutedamageoverlay3"
				if(45 to 70)
					I.icon_state = "brutedamageoverlay4"
				if(70 to 85)
					I.icon_state = "brutedamageoverlay5"
				if(85 to INFINITY)
					I.icon_state = "brutedamageoverlay6"

			var/image/black = image(I.icon, I.icon_state)
			black.color = "#170000"
			damageoverlay.overlays += I
			damageoverlay.overlays += black


		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
		else
			if(!client.adminobs)
				reset_view(null)

	handle_vision()
	handle_hud_icons()
	return 1


/mob/living/carbon/proc/handle_hud_icons()
	if(healths)
		if(stat == DEAD)
			healths.icon_state = "health7"
		else
			switch(hal_screwyhud)
				if(1)
					healths.icon_state = "health6"
				if(2)
					healths.icon_state = "health7"
				else
					switch(health - staminaloss)
						if(100 to INFINITY)
							healths.icon_state = "health0"
						if(80 to 100)
							healths.icon_state = "health1"
						if(60 to 80)
							healths.icon_state = "health2"
						if(40 to 60)
							healths.icon_state = "health3"
						if(20 to 40)
							healths.icon_state = "health4"
						if(0 to 20)
							healths.icon_state = "health5"
						else
							healths.icon_state = "health6"

	if(nutrition_icon)
		switch(nutrition)
			if(450 to INFINITY)
				nutrition_icon.icon_state = "nutrition0"
			if(350 to 450)
				nutrition_icon.icon_state = "nutrition1"
			if(250 to 350)
				nutrition_icon.icon_state = "nutrition2"
			if(150 to 250)
				nutrition_icon.icon_state = "nutrition3"
			else
				nutrition_icon.icon_state = "nutrition4"

	if(pressure)
		pressure.icon_state = "pressure[pressure_alert]"

	if(pullin)
		pullin.icon_state = "pull[pulling ? "":"0"]"

	if(toxin)
		if(halscreyhud == 4 || toxins_alert)
			toxin.icon_state = "tox1"
		else
			toxin.icon_state = "tox0"
	if(oxygen)
		if(hal_screwyhud == 3 || oxygen_alert)
			oxygen.icon_state = "oxy1"
		else
			oxygen.icon_state = "oxy0"
	if(fire)
		if(fire_alert)
			fire.icon_state = "fire[fire_alert]"
		else
			fire.icon_state = "fire0"


	if(bodytemp)
		switch(bodytemperature)
			if(370 to INFINITY)
				bodytemp.icon_state = "temp4"
			if(350 to 370)
				bodytemp.icon_state = "temp3"
			if(335 to 350)
				bodytemp.icon_state = "temp2"
			if(320 to 335)
				bodytemp.icon_state = "temp1"
			if(300 to 320)
				bodytemp.icon_state = "temp0"
			if(295 to 300)
				bodytemp.icon_state = "temp-1"
			if(280 to 295)
				bodytemp.icon_state = "temp-2"
			if(260 to 280)
				bodytemp.icon_state = "temp-3"
			if(-INFINITY to 260)
				bodytemp.icon_state = "temp-4"

	return 1


/mob/living/carbon/proc/handle_vision()
	if(stat == DEAD)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else if(stat != DEAD)
		sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		var/see_temp = see_invisible
		see_invisible = invis_sight
		see_in_dark = darksight

		if(XRAY in mutations)
			sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if(seer)
			see_invisible = SEE_INVISIBLE_OBSERVER

		if(druggy)
			see_invisible = see_temp
		if(see_override)
			see_invisible = see_override

		if(tinttotal >= TINT_IMPAIR)
			if(tinted_weldhelh)
				if(tinttotal >= TINT_BLIND)
					blinded = 1
				if(client)
					client.screen += gloabl_hud.darkMask

		if(blind)
			blind.layer = (blinded ? 18 : 0)


		if(client)
			if(eye_blurry)
				client.screen += global_hud.blurry
			if(druggy)
				client.screen += global_hud.druggy

			if(eye_stat > 20)
				if(eye_stat > 30)
					client.screen += global_hud.darkMask
				else
					client.screen += global_hud.vimpaired


	return 1


/mob/living/carbon/human/handle_vision()

	..()

	if(glasses)
		if(istype(glasses, /obj/item/clothing/glasses))
			var/obj/item/clothing/glasses/G = glasses
			sight |= G.vision_flags
			see_in_dark = G.darkness_view
			see_invisible = G.inviw_view

		if(disabilities & NEARSIGHTED && !istype(glasses, /obj/item/clothing/glasses/regular))
			if(client)
				client.screen += global_hud.vimpaired

