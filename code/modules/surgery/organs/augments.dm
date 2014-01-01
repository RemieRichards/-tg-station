 /////AUGMENTATION\\\\\


/obj/item/augment
	name = "cyberlimb"
	desc = "You should never be seeing this!"
	icon = 'icons/mob/augments.dmi'
	var/limb_part = null
	var/bonus = BONUS_NONE

/obj/item/augment/chest
	name = "chest"
	desc = "A Robotic chest"
	icon_state = "chest_s"
	limb_part = CHEST

/obj/item/augment/head
	name = "head"
	desc = "A Robotic head"
	icon_state = "head_s"
	limb_part = HEAD

/obj/item/augment/l_arm
	name = "left arm"
	desc = "A Robotic arm"
	icon_state = "l_arm_s"
	limb_part = ARM_LEFT

/obj/item/augment/l_leg
	name = "left leg"
	desc = "A Robotic leg"
	icon_state = "l_leg_s"
	limb_part = LEG_LEFT

/obj/item/augment/r_arm
	name = "right arm"
	desc = "A Robotic arm"
	icon_state = "r_arm_s"
	limb_part = ARM_RIGHT

/obj/item/augment/r_leg
	name = "right leg"
	desc = "A Robotic leg"
	icon_state = "r_leg_s"
	limb_part = LEG_RIGHT

/obj/item/augment/blade_arm
	name = "blade arm"
	desc = "A Robotic blade-arm"
	icon_state = "blade_arm"
	limb_part = ARM_RIGHT
	bonus = BONUS_BLADE



/obj/item/augment/blade_arm/New() //Randomises which side the arm goes on.
	..()
	if(prob(50))
		name = "left blade arm"
		limb_part = ARM_LEFT


/mob/living/carbon/human/proc/handle_augment_bonus()
	for(var/obj/item/organ/limb/affecting in organs)
		if(affecting.status == ORGAN_ROBOTIC)
			switch(affecting.bonus)
				if(BONUS_BLADE)
					verbs += /mob/living/carbon/human/verb/blade_arm
				if(BONUS_GUN)
					verbs += /mob/living/carbon/human/verb/gun_arm
		else
			verbs -= /mob/living/carbon/human/verb/blade_arm
			verbs -= /mob/living/carbon/human/verb/gun_arm


//BLADE ARMS\\

/mob/living/carbon/human/verb/blade_arm()
	set name = "Hidden Blade"
	set category = "Augments"
	set desc = "Reveal a hidden blade from your arm"

	var/obj/item/weapon/melee/aug_blade/AB = new()

	if(!get_active_hand()&&!istype(get_inactive_hand(), /obj/item/weapon/melee/aug_blade))
		put_in_hands(AB)


/obj/item/weapon/melee/aug_blade
	name = "Blade augment"
	desc = "A sharp blade that can be hidden in a robotic arm"
	icon_state = "aug_blade"
	force = 50.0//
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 1
	throw_range = 1
	w_class = 4.0//So you can't hide it in your pocket or some such.
	flags = FPRINT | TABLEPASS | NOSHIELD | NOBLOODY | SHARP
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp_power = 30

/obj/item/weapon/melee/aug_blade/dropped()
	del(src)

/obj/item/weapon/melee/aug_blade/proc/throw()
	del(src)


//GUN ARMS\\

/mob/living/carbon/human/verb/gun_arm()
	set name = "Hidden Gun"
	set category = "Augments"
	set desc = "Reveal a hidden gun from your arm"

	var/obj/item/weapon/gun/energy/laser/captain/aug_gun/AG = new()

	if(!get_active_hand()&&!istype(get_inactive_hand(), /obj/item/weapon/gun/energy/laser/captain/aug_gun))
		put_in_hands(AG)



/obj/item/weapon/gun/energy/laser/captain/aug_gun //Sub class of Captain's fot the laser recharge code.
	name = "Gun augment"
	icon_state = "aug_gun"
	desc = "A semi-powerful laser gun that recharges over time."
	force = 15
	throwforce = 1
	throw_speed = 1
	throw_range = 1
	w_class = 4.0

/obj/item/weapon/gun/energy/laser/captain/aug_gun/dropped()
	del(src)

/obj/item/weapon/gun/energy/laser/captain/aug_gun/proc/throw()
	del(src)
