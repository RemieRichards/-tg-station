
//REMOVING LIMBS\\\

/datum/surgery_step/remove_limb
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 32
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg","chest","head")


/datum/surgery_step/remove_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to sever [target]'s [parse_zone(user.zone_sel.selecting)] muscle.</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>")


/datum/surgery_step/remove_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			L.state = ORGAN_REMOVED
			if(L.body_part == HEAD)
				user.visible_message("<span class='notice'>[user] successfully removes some flesh around [target]'s [parse_zone(user.zone_sel.selecting.)]!</span>")
			else
				user.visible_message("<span class='notice'>[user] successfully removes [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
				L.drop_limb(H)
			H.update_body()
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Removed [target.name]'s [parse_zone(user.zone_sel.selecting)] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
			target.attack_log += "\[[time_stamp()]\]<font color='orange'> limb removed by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) removed limb of [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[user] [target] has no [parse_zone(user.zone_sel.selecting)] there!</span>")
	return 1


/datum/surgery/removal
	name = "removal"
	steps = list(/datum/surgery_step/incise ,/datum/surgery_step/saw, /datum/surgery_step/remove_limb)
	species = list(/mob/living/carbon/human)
	location = "anywhere"
	has_multi_loc = 1


//Organic Limb Reattachment\\

/datum/surgery_step/reattachment
	implements = list(/obj/item/organ/limb = 100)
	time = 48
	var/obj/item/organ/limb/L = null // L because "limb"
	allowed_organs = list("r_arm","l_arm","r_leg","l_leg")


/datum/surgery_step/reattachment/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = new_organ
	if(L)
		user.visible_message("<span class ='notice'>[user] begins to reattach [target]'s [parse_zone(user.zone_sel.selecting)].</span>")
	else
		user.visible_message("<span class ='notice'>[user] looks for [target]'s [parse_zone(user.zone_sel.selecting)].</span>") //Should never Naturally happen.


/datum/surgery_step/reattachment/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L.state == ORGAN_REMOVED)
		var/mob/living/carbon/human/H = target
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s [parse_zone(user.zone_sel.selecting)]!</span>")
		L.state = ORGAN_FINE
		L.burn_dam = 0
		L.brute_dam = 0
		H.updatehealth()
		H.update_body()
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Reattached [target.name]'s [parse_zone(user.zone_sel.selecting)] ([target.ckey]) INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> limb reattached by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		log_attack("<font color='red'>[user.name] ([user.ckey]) reattached limb of [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	else
		user.visible_message("<span class='notice'>[target]'s [parse_zone(user.zone_sel.selecting)] is still there!</span>")
	return 1

/datum/surgery_step/clean_wound
	implements = list(/obj/item/weapon/scalpel)
	time = 16

/datum/surgery_step/clean_wound/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to clean the flesh aroumd where [target]'s [parse_zone(target_zone)] should go.</span>")


/datum/surgery/reattachment
	name = "reattachment"
	steps = list(/datum/surgery_step/clean_wound, /datum/surgery_step/reattachment, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	location = "anywhere"
	has_multi_loc = 1
