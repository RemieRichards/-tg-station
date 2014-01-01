/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/status = ORGAN_ORGANIC
	var/state = ORGAN_FINE



/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	var/beating = 1

/obj/item/organ/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"


/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	var/inflamed = 1

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"


//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

//Old Datum Limbs:
// code/modules/unused/limbs.dm


/obj/item/organ/limb
	name = "limb"
	var/mob/owner = null
	var/body_part = null
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_damage = 0
	var/dam_icon = "chest" //So damage icons are not tied to the icon_state of the obj - RR
	var/bonus = BONUS_NONE


/obj/item/organ/limb/chest
	name = "chest"
	desc = "why is it detached..."
	icon_state = "chest"
	dam_icon = "chest"
	max_damage = 200
	body_part = CHEST


/obj/item/organ/limb/head
	name = "head"
	desc = "what a way to get a head in life..."
	icon_state = "head"
	dam_icon = "head"
	max_damage = 200
	body_part = HEAD


/obj/item/organ/limb/l_arm
	name = "l_arm"
	desc = "why is it detached..."
	icon_state = "l_arm"
	dam_icon = "l_arm"
	max_damage = 75
	body_part = ARM_LEFT


/obj/item/organ/limb/l_leg
	name = "l_leg"
	desc = "why is it detached..."
	icon_state = "l_leg"
	dam_icon = "l_leg"
	max_damage = 75
	body_part = LEG_LEFT


/obj/item/organ/limb/r_arm
	name = "r_arm"
	desc = "why is it detached..."
	icon_state = "r_arm"
	dam_icon = "r_arm"
	max_damage = 75
	body_part = ARM_RIGHT


/obj/item/organ/limb/r_leg
	name = "r_leg"
	desc = "why is it detached..."
	icon_state = "r_leg"
	dam_icon = "r_leg"
	max_damage = 75
	body_part = LEG_RIGHT


//////////////// DAMAGE PROCS \\\\\\\\\\\\\\\\

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/organ/limb/proc/take_damage(brute, burn)
	if(owner && (owner.status_flags & GODMODE))	return 0	//godmode
	brute	= max(brute,0)
	burn	= max(burn,0)


	if(status == ORGAN_ROBOTIC) //This makes robolimbs not damageable by chems and makes it stronger
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	var/can_inflict = max_damage - (brute_dam + burn_dam)
	if(!can_inflict)	return 0

	if((brute + burn) < can_inflict)
		brute_dam	+= brute
		burn_dam	+= burn
	else
		if(brute > 0)
			if(burn > 0)
				brute	= round( (brute/(brute+burn)) * can_inflict, 1 )
				burn	= can_inflict - brute	//gets whatever damage is left over
				brute_dam	+= brute
				burn_dam	+= burn
			else
				brute_dam	+= can_inflict
		else
			if(burn > 0)
				burn_dam	+= can_inflict
			else
				return 0
	return update_organ_icon()


//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/organ/limb/proc/heal_damage(brute, burn, var/robotic)

	if(robotic && status != ORGAN_ROBOTIC) // This makes organic limbs not heal when the proc is in Robotic mode.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	if(!robotic && status == ORGAN_ROBOTIC) // This makes robolimbs not healable by chems.
		brute = max(0, brute - 3)
		burn = max(0, burn - 3)

	brute_dam	= max(brute_dam - brute, 0)
	burn_dam	= max(burn_dam - burn, 0)
	return update_organ_icon()


//Returns total damage...kinda pointless really
/obj/item/organ/limb/proc/get_damage()
	return brute_dam + burn_dam



//////////////// DISPLAY PROCS \\\\\\\\\\\\\\\\

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/organ/limb/proc/update_organ_icon()
	if(status == ORGAN_ORGANIC) //Robotic limbs show no damage - RR
		var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
		var/tburn	= round( (burn_dam/max_damage)*3, 1 )
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0

//Returns a display name for the organ
/obj/item/organ/limb/proc/getDisplayName() //Added "Chest" and "Head" just in case, this may not be needed - RR.
	switch(name)
		if("l_leg")		return "left leg"
		if("r_leg")		return "right leg"
		if("l_arm")		return "left arm"
		if("r_arm")		return "right arm"
		if("chest")     return "chest"
		if("head")		return "head"
		else			return name


//////////////// DISMEMBERMENT \\\\\\\\\\\\\\\\

/obj/item/organ/limb/proc/dismember(var/obj/item/I, var/removal_type)
	var/obj/item/organ/limb/affecting = src

	var/mob/living/carbon/human/owner = affecting.owner

	var/dismember_chance = 0 //Chance for the limb to fall off, if an Item is used the it is the item's sharp_power

	var/removal_word = "" //Differs based on how the limb was removed

	switch(removal_type)
		if(EXPLOSION)
			removal_word = "blown"
			dismember_chance = 45
		if(GUN)
			removal_word = "shot"
		else //Spelling mistake or Melee
			removal_word = "chopped"

	if(I)
		dismember_chance = I.sharp_power


	if(affecting.brute_dam >= (affecting.max_damage / 2) && affecting.state != ORGAN_REMOVED) //if it has taken significant enough damage
		if(prob(dismember_chance)) //Probaility can be a unique variable for each item.
			owner.apply_damage(30,"brute","[affecting]")
			if(istype(affecting, /obj/item/organ/limb/head))
				for(var/obj/item/organ/brain/B in owner.internal_organs)
					owner.internal_organs -= B
					affecting.contents += B //Put the brain in the head
					owner.u_equip(owner.glasses) //Drop their head clothing
					owner.u_equip(owner.head)
					owner.u_equip(owner.ears)
					owner.u_equip(owner.wear_mask)
			if(istype(affecting, /obj/item/organ/limb/chest))
				for(var/obj/item/organ/O in owner.internal_organs)
					if(!istype(O, /obj/item/organ/brain))
						owner.internal_organs -= O
						O.loc = get_turf(owner)
			if(istype(affecting, /obj/item/organ/limb/r_arm) || istype(affecting, /obj/item/organ/limb/l_arm))
				if(owner.handcuffed)
					owner.handcuffed.loc = owner.loc
					owner.handcuffed = null
					owner.update_inv_handcuffed(0)
			if(istype(affecting, /obj/item/organ/limb/r_leg) || istype(affecting, /obj/item/organ/limb/l_leg))
				if(owner.legcuffed)
					owner.legcuffed.loc = owner.loc
					owner.legcuffed = null
					owner.update_inv_legcuffed(0)

			affecting.state = ORGAN_REMOVED

			affecting.drop_limb(owner)

			if(affecting.name != "chest")
				owner.visible_message("<span class='danger'><B>[owner]'s [affecting.getDisplayName()] has been [removal_word] off!</B></span>")
			else
				owner.visible_message("<span class='danger'><B>[owner]'s internal organs have spilled onto the floor!</B></span>")

		owner.drop_both_hands() //Removes any items they may be carrying in their now non existant arms
	owner.update_body()



//////////////// AUGMENTATION \\\\\\\\\\\\\\\\

/mob/living/carbon/human/proc/augmentation(var/obj/item/organ/limb/affecting, var/mob/user, var/obj/item/I)
	if(affecting.state == ORGAN_REMOVED)
		var/obj/item/augment/AUG = I
		if(affecting.body_part == AUG.limb_part)
			affecting.Robotize()
			affecting.bonus = AUG.bonus
			visible_message("<span class='notice'>[user] has attached [src]'s new limb!</span>")
		else
			user << "<span class='notice'>You can't attach a [AUG.name] where [src]'s [affecting.getDisplayName()] should be!</span>"
			return

		if(affecting.name == "chest" && affecting.body_part == AUG.limb_part)
			for(var/datum/disease/appendicitis/A in viruses)
				A.cure(1)

		user.drop_item()
		del(AUG)
		update_body()
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Augmented [src.name]'s [parse_zone(user.zone_sel.selecting)] ([src.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		src.attack_log += "\[[time_stamp()]\]<font color='orange'> Augmented by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) augmented [src.name] ([src.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")




//////////////// LIMB STATUS \\\\\\\\\\\\\\\\

//Informs us if the user has atleast 1 functional Arm.
/mob/living/carbon/human/proc/arm_ok()
	var/num_of_arms = 0

	for(var/obj/item/organ/limb/affecting in organs)
		if(affecting.name == "r_arm" || affecting.name == "l_arm")
			if(affecting.state == ORGAN_FINE)
				num_of_arms += 1


	if(num_of_arms == 1 || num_of_arms == 2)
		return 1
	else
		return 0

//Informs us if the user has atleast 1 functional Leg.
/mob/living/carbon/human/proc/leg_ok()
	var/num_of_legs = 0

	for(var/obj/item/organ/limb/affecting in organs)
		if(affecting.name == "r_leg" || affecting.name == "l_leg")
			if(affecting.state == ORGAN_FINE)
				num_of_legs += 1


	if(num_of_legs == 1 || num_of_legs == 2)
		return 1
	else
		return 0


//////////////// ROBOTIZE \\\\\\\\\\\\\\\\

/mob/living/carbon/human/proc/Robotize_organs(var/internal, var/limbs)
	if(limbs)
		for(var/obj/item/organ/limb/L in organs)
			L.Robotize()

	if(internal)
		for(var/obj/item/organ/O in internal_organs)
			O.Robotize()


/obj/item/organ/proc/Robotize()

	state = ORGAN_FINE
	status = ORGAN_ROBOTIC

	if(istype(src,/obj/item/organ/limb))
		var/obj/item/organ/limb/L = src
		L.burn_dam = 0
		L.brute_dam = 0

		if(L.owner)
			var/mob/living/carbon/human/H = L.owner //Only humans have Organs and Organ/limbs.
			H.updatehealth()
			H.update_body()


//////////////// DROP LIMB \\\\\\\\\\\\\\\\

/obj/item/organ/limb/proc/drop_limb(var/location) //Dummy limbs.
	var/obj/item/organ/limb/LIMB
	var/Loc

	if(location)
		Loc = get_turf(location)
	else
		Loc = get_turf(src)

	if(status == ORGAN_ORGANIC)
		switch(body_part)
			if(HEAD)
				LIMB = new /obj/item/organ/limb/head (Loc)
			//No chests, they can't be removed
			if(ARM_RIGHT)
				LIMB = new /obj/item/organ/limb/r_arm (Loc)
			if(ARM_LEFT)
				LIMB = new /obj/item/organ/limb/l_arm (Loc)
			if(LEG_RIGHT)
				LIMB = new /obj/item/organ/limb/r_leg (Loc)
			if(LEG_LEFT)
				LIMB = new /obj/item/organ/limb/l_leg (Loc)
	else if(status == ORGAN_ROBOTIC)
		switch(body_part)
			if(HEAD)
				LIMB = new /obj/item/augment/head (Loc)
			//No chests, they can't be removed
			if(ARM_RIGHT)
				LIMB = new /obj/item/augment/r_arm (Loc)
			if(ARM_LEFT)
				LIMB = new /obj/item/augment/l_arm (Loc)
			if(LEG_RIGHT)
				LIMB = new /obj/item/augment/r_leg (Loc)
			if(LEG_LEFT)
				LIMB = new /obj/item/augment/l_leg (Loc)

	var/direction = pick(cardinal)
	step(LIMB,direction) //Make the limb fly off

