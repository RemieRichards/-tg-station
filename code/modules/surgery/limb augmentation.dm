
//REMOVING LIMBS\\\


/datum/surgery_step/remove_limb
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head")


/datum/surgery_step/remove_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to remove [target]'s [parse_zone(user.zone_sel.selecting)].</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>")


/datum/surgery_step/remove_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			user.visible_message("<span class='notice'>[user] successfully removes [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
			L.state = ORGAN_REMOVED
			dummy_limbs(L, src)
			H.update_damage_overlays(0)
			H.update_body()
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Removed [target.name]'s [parse_zone(user.zone_sel.selecting)] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
			target.attack_log += "\[[time_stamp()]\]<font color='orange'> limb removed by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) removed limb of [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no [parse_zone(user.zone_sel.selecting)] there!</span>")
	return 1


/datum/surgery/removal
	name = "removal"
	steps = list(/datum/surgery_step/remove_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere"
	has_multi_loc = 1


/proc/dummy_limbs(var/obj/item/organ/limb/limb_to_form_dummy_of, var/location) //Dummy limbs.
	var/obj/item/organ/limb/ACTIVE
	var/Loc = get_turf(location)

	if(limb_to_form_dummy_of.status == ORGAN_ORGANIC)
		switch(limb_to_form_dummy_of.body_part)
			if(HEAD)
				ACTIVE = /obj/item/organ/limb/head
			//No chests, they can't be removed
			if(ARM_RIGHT)
				ACTIVE = /obj/item/organ/limb/r_arm
			if(ARM_LEFT)
				ACTIVE = /obj/item/organ/limb/l_arm
			if(LEG_RIGHT)
				ACTIVE = /obj/item/organ/limb/r_leg
			if(LEG_LEFT)
				ACTIVE = /obj/item/organ/limb/l_leg
	else if(limb_to_form_dummy_of.status == ORGAN_ROBOTIC)
		switch(limb_to_form_dummy_of.body_part)
			if(HEAD)
				ACTIVE = /obj/item/augment/head
			//No chests, they can't be removed
			if(ARM_RIGHT)
				ACTIVE = /obj/item/augment/r_arm
			if(ARM_LEFT)
				ACTIVE = /obj/item/augment/l_arm
			if(LEG_RIGHT)
				ACTIVE = /obj/item/augment/r_leg
			if(LEG_LEFT)
				ACTIVE = /obj/item/augment/l_leg
	new ACTIVE (Loc)