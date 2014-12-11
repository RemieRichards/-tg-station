// This code handles different species in the game.

#define SPECIES_LAYER			23
#define BODY_LAYER				22
#define HAIR_LAYER				8

#define TINT_IMPAIR 2
#define TINT_BLIND 3

#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS ( (last_tick_duration) /3)

#define HEAT_DAMAGE_LEVEL_1 2
#define HEAT_DAMAGE_LEVEL_2 3
#define HEAT_DAMAGE_LEVEL_3 8

#define COLD_DAMAGE_LEVEL_1 0.5
#define COLD_DAMAGE_LEVEL_2 1.5
#define COLD_DAMAGE_LEVEL_3 3

#define HEAT_GAS_DAMAGE_LEVEL_1 2
#define HEAT_GAS_DAMAGE_LEVEL_2 4
#define HEAT_GAS_DAMAGE_LEVEL_3 8

#define COLD_GAS_DAMAGE_LEVEL_1 0.5
#define COLD_GAS_DAMAGE_LEVEL_2 1.5
#define COLD_GAS_DAMAGE_LEVEL_3 3

/datum/species
	var/id = null		// if the game needs to manually check your race to do something not included in a proc here, it will use this
	var/name = null		// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	var/roundstart = 0	// can this mob be chosen at roundstart? (assuming the config option is checked?)
	var/default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race

	var/eyes = "eyes"	// which eyes the race uses. at the moment, the only types of eyes are "eyes" (regular eyes) and "jelleyes" (three eyes)
	var/sexes = 1		// whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows
	var/hair_color = null	// this allows races to have specific hair colors... if null, it uses the H's hair/facial hair colors. if "mutcolor", it uses the H's mutant_color
	var/hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.
	var/use_skintones = 0	// does it use skintones or not? (spoiler alert this is only used by humans)
	var/meat = /obj/item/weapon/reagent_containers/food/snacks/meat/human //What the species drops on gibbing
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids

	var/say_mod = "says"	// affects the speech message

	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/armor = 0		// overall defense for the race... or less defense, if it's negative.
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/punchmod = 0	// adds to the punch damage

	var/invis_sight = SEE_INVISIBLE_LIVING
	var/darksight = 2

	// species flags. these can be found in flags.dm
	var/list/specflags = list()

	var/attack_verb = "punch"	// punch-specific attack verb
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	var/mob/living/list/ignored_by = list()	// list of mobs that will ignore this species

	///////////
	// PROCS //
	///////////

/datum/species/proc/update_base_icon_state(var/mob/living/carbon/human/H)
	if(HUSK in H.mutations)
		H.remove_overlay(SPECIES_LAYER) // races lose their color
		return "husk"
	else if(sexes)
		if(use_skintones)
			return "[H.skin_tone]_[(H.gender == FEMALE) ? "f" : "m"]"
		else
			return "[id]_[(H.gender == FEMALE) ? "f" : "m"]"
	else
		return "[id]"

/datum/species/proc/update_color(var/mob/living/carbon/human/H)
	H.remove_overlay(SPECIES_LAYER)

	var/image/standing

	var/g = (H.gender == FEMALE) ? "f" : "m"

	if(MUTCOLORS in specflags)
		var/image/spec_base
		if(sexes)
			spec_base = image("icon" = 'icons/mob/human.dmi', "icon_state" = "[id]_[g]_s", "layer" = -SPECIES_LAYER)
		else
			spec_base = image("icon" = 'icons/mob/human.dmi', "icon_state" = "[id]_s", "layer" = -SPECIES_LAYER)
		if(!config.mutant_colors)
			H.dna.mutant_color = default_color
		spec_base.color = "#[H.dna.mutant_color]"
		standing = spec_base

	if(standing)
		H.overlays_standing[SPECIES_LAYER]	= standing

	H.apply_overlay(SPECIES_LAYER)

/datum/species/proc/handle_hair(var/mob/living/carbon/human/H)
	H.remove_overlay(HAIR_LAYER)

	var/datum/sprite_accessory/S
	var/list/standing	= list()

	if(H.facial_hair_style && FACEHAIR in specflags)
		S = facial_hair_styles_list[H.facial_hair_style]
		if(S)
			var/image/img_facial_s

			img_facial_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			if(hair_color)
				if(hair_color == "mutcolor")
					if(!config.mutant_colors)
						img_facial_s.color = "#" + default_color
					else
						img_facial_s.color = "#" + H.dna.mutant_color
				else
					img_facial_s.color = "#" + hair_color
			else
				img_facial_s.color = "#" + H.facial_hair_color
			img_facial_s.alpha = hair_alpha

			standing	+= img_facial_s

	//Applies the debrained overlay if there is no brain
	if(!H.getorgan(/obj/item/organ/brain))
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state" = "debrained_s", "layer" = -HAIR_LAYER)

	else if(H.hair_style && HAIR in specflags)
		S = hair_styles_list[H.hair_style]
		if(S)
			var/image/img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			img_hair_s = image("icon" = S.icon, "icon_state" = "[S.icon_state]_s", "layer" = -HAIR_LAYER)

			if(hair_color)
				if(hair_color == "mutcolor")
					if(!config.mutant_colors)
						img_hair_s.color = "#" + default_color
					else
						img_hair_s.color = "#" + H.dna.mutant_color
				else
					img_hair_s.color = "#" + hair_color
			else
				img_hair_s.color = "#" + H.hair_color
			img_hair_s.alpha = hair_alpha

			standing	+= img_hair_s

	if(standing.len)
		H.overlays_standing[HAIR_LAYER]	= standing

	H.apply_overlay(HAIR_LAYER)

	return

/datum/species/proc/handle_body(var/mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing	= list()

	// lipstick
	if(H.lip_style && LIPS in specflags)
		standing	+= image("icon"='icons/mob/human_face.dmi', "icon_state"="lips_[H.lip_style]_s", "layer" = -BODY_LAYER)

	// eyes
	if(EYECOLOR in specflags)
		var/image/img_eyes_s = image("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[eyes]_s", "layer" = -BODY_LAYER)
		img_eyes_s.color = "#" + H.eye_color
		standing	+= img_eyes_s

	//Underwear & Undershirts
	if(H.underwear)
		var/datum/sprite_accessory/underwear/U = underwear_list[H.underwear]
		if(U)
			standing	+= image("icon"=U.icon, "icon_state"="[U.icon_state]_s", "layer"=-BODY_LAYER)

	if(H.undershirt)
		var/datum/sprite_accessory/undershirt/U2 = undershirt_list[H.undershirt]
		if(U2)
			if(H.dna && H.dna.species.sexes && H.gender == FEMALE)
				standing	+=	H.wear_female_version(U2.icon_state, U2.icon, BODY_LAYER)
			else
				standing	+= image("icon"=U2.icon, "icon_state"="[U2.icon_state]_s", "layer"=-BODY_LAYER)

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)

	return

/datum/species/proc/spec_life(var/mob/living/carbon/human/H)
	return

/datum/species/proc/spec_death(var/gibbed, var/mob/living/carbon/human/H)
	return

/datum/species/proc/auto_equip(var/mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(var/obj/item/I, var/slot, var/disable_warning, var/mob/living/carbon/human/H)
	if(slot in no_equip)
		if(!(type in I.species_exception))
			return 0

	switch(slot)
		if(slot_l_hand)
			if(H.l_hand)
				return 0
			return 1
		if(slot_r_hand)
			if(H.r_hand)
				return 0
			return 1
		if(slot_wear_mask)
			if(H.wear_mask)
				return 0
			if( !(I.slot_flags & SLOT_MASK) )
				return 0
			return 1
		if(slot_back)
			if(H.back)
				return 0
			if( !(I.slot_flags & SLOT_BACK) )
				return 0
			return 1
		if(slot_wear_suit)
			if(H.wear_suit)
				return 0
			if( !(I.slot_flags & SLOT_OCLOTHING) )
				return 0
			return 1
		if(slot_gloves)
			if(H.gloves)
				return 0
			if( !(I.slot_flags & SLOT_GLOVES) )
				return 0
			return 1
		if(slot_shoes)
			if(H.shoes)
				return 0
			if( !(I.slot_flags & SLOT_FEET) )
				return 0
			return 1
		if(slot_belt)
			if(H.belt)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='danger'>You need a jumpsuit before you can attach this [I.name].</span>"
				return 0
			if( !(I.slot_flags & SLOT_BELT) )
				return
			return 1
		if(slot_glasses)
			if(H.glasses)
				return 0
			if( !(I.slot_flags & SLOT_EYES) )
				return 0
			return 1
		if(slot_head)
			if(H.head)
				return 0
			if( !(I.slot_flags & SLOT_HEAD) )
				return 0
			return 1
		if(slot_ears)
			if(H.ears)
				return 0
			if( !(I.slot_flags & SLOT_EARS) )
				return 0
			return 1
		if(slot_w_uniform)
			if(H.w_uniform)
				return 0
			if( !(I.slot_flags & SLOT_ICLOTHING) )
				return 0
			return 1
		if(slot_wear_id)
			if(H.wear_id)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='danger'>You need a jumpsuit before you can attach this [I.name].</span>"
				return 0
			if( !(I.slot_flags & SLOT_ID) )
				return 0
			return 1
		if(slot_l_store)
			if(I.flags & NODROP) //Pockets aren't visible, so you can't move NODROP items into them.
				return 0
			if(H.l_store)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='danger'>You need a jumpsuit before you can attach this [I.name].</span>"
				return 0
			if(I.slot_flags & SLOT_DENYPOCKET)
				return
			if( I.w_class <= 2 || (I.slot_flags & SLOT_POCKET) )
				return 1
		if(slot_r_store)
			if(I.flags & NODROP)
				return 0
			if(H.r_store)
				return 0
			if(!H.w_uniform && !nojumpsuit)
				if(!disable_warning)
					H << "<span class='danger'>You need a jumpsuit before you can attach this [I.name].</span>"
				return 0
			if(I.slot_flags & SLOT_DENYPOCKET)
				return 0
			if( I.w_class <= 2 || (I.slot_flags & SLOT_POCKET) )
				return 1
			return 0
		if(slot_s_store)
			if(I.flags & NODROP)
				return 0
			if(H.s_store)
				return 0
			if(!H.wear_suit)
				if(!disable_warning)
					H << "<span class='danger'>You need a suit before you can attach this [I.name].</span>"
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					H << "You somehow have a suit with no defined allowed items for suit storage, stop that."
				return 0
			if(I.w_class > 4)
				if(!disable_warning)
					H << "The [I.name] is too big to attach."  //should be src?
				return 0
			if( istype(I, /obj/item/device/pda) || istype(I, /obj/item/weapon/pen) || is_type_in_list(I, H.wear_suit.allowed) )
				return 1
			return 0
		if(slot_handcuffed)
			if(H.handcuffed)
				return 0
			if(!istype(I, /obj/item/weapon/restraints/handcuffs))
				return 0
			return 1
		if(slot_legcuffed)
			if(H.legcuffed)
				return 0
			if(!istype(I, /obj/item/weapon/restraints/legcuffs))
				return 0
			return 1
		if(slot_in_backpack)
			if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = H.back
				if(B.contents.len < B.storage_slots && I.w_class <= B.max_w_class)
					return 1
			return 0
	return 0 //Unsupported slot

/datum/species/proc/before_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	return

/datum/species/proc/after_equip_job(var/datum/job/J, var/mob/living/carbon/human/H)
	return

/datum/species/proc/handle_chemicals(var/datum/reagent/chem, var/mob/living/carbon/human/H)
	return 0

/datum/species/proc/handle_speech(var/message, var/mob/living/carbon/human/H)
	return message

////////
//LIFE//
////////


////////////////
// MOVE SPEED //
////////////////

/datum/species/proc/movement_delay(var/mob/living/carbon/human/H)
	var/mspeed = 0
	if(H.status_flags & GOTTAGOFAST)
		mspeed -= 1

	if(!has_gravity(H))
		mspeed += 1.5 //Carefully propelling yourself along the walls is actually quite slow

		if(istype(H.back, /obj/item/weapon/tank/jetpack))
			var/obj/item/weapon/tank/jetpack/J = H.back
			if(J.allow_thrust(0.01, H))
				mspeed -= 2.5

		if(H.l_hand) //Having your hands full makes movement harder when you're weightless. You try climbing around while holding a gun!
			mspeed += 0.5
		if(H.r_hand)
			mspeed += 0.5
		if(H.r_hand && H.l_hand)
			mspeed += 0.5

	var/health_deficiency = (100 - H.health + H.staminaloss)
	if(health_deficiency >= 40)
		mspeed += (health_deficiency / 25)

	var/hungry = (500 - H.nutrition) / 5	//So overeat would be 100 and default level would be 80
	if(hungry >= 70)
		mspeed += hungry / 50

	if(H.wear_suit)
		mspeed += H.wear_suit.slowdown
	if(H.shoes)
		mspeed += H.shoes.slowdown
	if(H.back)
		mspeed += H.back.slowdown

	if(FAT in H.mutations)
		mspeed += 1.5
	if(H.bodytemperature < 283.222)
		mspeed += (283.222 - H.bodytemperature) / 10 * 1.75

	mspeed += speedmod

	return mspeed

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/spec_attack_hand(var/mob/living/carbon/human/M, var/mob/living/carbon/human/H)
	if((M != H) && H.check_shields(0, M.name))
		add_logs(M, H, "attempted to touch")
		H.visible_message("<span class='warning'>[M] attempted to touch [H]!</span>")
		return 0

	switch(M.a_intent)
		if("help")
			if(H.health >= 0)
				H.help_shake_act(M)
				if(H != M)
					add_logs(M, H, "shaked")
				return 1

			//CPR
			if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
				M << "<span class='notice'>Remove your mask!</span>"
				return 0
			if((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
				M << "<span class='notice'>Remove their mask!</span>"
				return 0

			if(H.cpr_time < world.time + 30)
				add_logs(H, M, "CPRed")
				M.visible_message("<span class='notice'>[M] is trying to perform CPR on [H]!</span>", \
								"<span class='notice'>You try to perform CPR on [H]. Hold still!</span>")
				if(!do_mob(M, H))
					M << "<span class='warning'>You fail to perform CPR on [H]!</span>"
					return 0
				if((H.health >= -99 && H.health <= 0))
					H.cpr_time = world.time
					var/suff = min(H.getOxyLoss(), 7)
					H.adjustOxyLoss(-suff)
					H.updatehealth()
					M.visible_message("[M] performs CPR on [H]!")
					H << "<span class='unconscious'>You feel a breath of fresh air enter your lungs. It feels good.</span>"

		if("grab")
			H.grabbedby(M)
			return 1

		if("harm")
			add_logs(M, H, "punched")
			M.do_attack_animation(H)

			var/atk_verb = "punch"
			if(H.lying)
				atk_verb = "kick"
			else if(M.dna)
				atk_verb = M.dna.species.attack_verb

			var/damage = rand(0, 9)
			damage += punchmod

			if(!damage)
				if(M.dna)
					playsound(H.loc, M.dna.species.miss_sound, 25, 1, -1)
				else
					playsound(H.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

				H.visible_message("<span class='warning'>[M] has attempted to [atk_verb] [H]!</span>")
				return 0


			var/obj/item/organ/limb/affecting = H.get_organ(ran_zone(M.zone_sel.selecting))
			var/armor_block = H.run_armor_check(affecting, "melee")

			if(HULK in M.mutations)
				damage += 5

			if(M.dna)
				playsound(H.loc, M.dna.species.attack_sound, 25, 1, -1)
			else
				playsound(H.loc, 'sound/weapons/punch1.ogg', 25, 1, -1)


			H.visible_message("<span class='danger'>[M] has [atk_verb]ed [H]!</span>", \
							"<span class='userdanger'>[M] has [atk_verb]ed [H]!</span>")

			H.apply_damage(damage, BRUTE, affecting, armor_block)
			if((H.stat != DEAD) && damage >= 9)
				H.visible_message("<span class='danger'>[M] has weakened [H]!</span>", \
								"<span class='userdanger'>[M] has weakened [H]!</span>")
				H.apply_effect(4, WEAKEN, armor_block)
				H.forcesay(hit_appends)
			else if(H.lying)
				H.forcesay(hit_appends)

		if("disarm")
			M.do_attack_animation(H)
			add_logs(M, H, "disarmed")

			if(H.w_uniform)
				H.w_uniform.add_fingerprint(M)
			var/obj/item/organ/limb/affecting = H.get_organ(ran_zone(M.zone_sel.selecting))
			var/randn = rand(1, 100)
			if(randn <= 25)
				H.apply_effect(2, WEAKEN, H.run_armor_check(affecting, "melee"))
				playsound(H, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				H.visible_message("<span class='danger'>[M] has pushed [H]!</span>",
								"<span class='userdanger'>[M] has pushed [H]!</span>")
				H.forcesay(hit_appends)
				return

			var/talked = 0	// BubbleWrap

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(H.pulling)
					H.visible_message("<span class='warning'>[M] has broken [H]'s grip on [H.pulling]!</span>")
					talked = 1
					H.stop_pulling()

				//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
				if(istype(H.l_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/lgrab = H.l_hand
					if(lgrab.affecting)
						H.visible_message("<span class='warning'>[M] has broken [H]'s grip on [lgrab.affecting]!</span>")
						talked = 1
					spawn(1)
						qdel(lgrab)
				if(istype(H.r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = H.r_hand
					if(rgrab.affecting)
						H.visible_message("<span class='warning'>[M] has broken [H]'s grip on [rgrab.affecting]!</span>")
						talked = 1
					spawn(1)
						qdel(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					if(H.drop_item())
						H.visible_message("<span class='danger'>[M] has disarmed [H]!</span>", \
										"<span class='userdanger'>[M] has disarmed [H]!</span>")
				playsound(H, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return


			playsound(H, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			H.visible_message("<span class='danger'>[M] attempted to disarm [H]!</span>", \
							"<span class='userdanger'>[M] attemped to disarm [H]!</span>")
	return

/datum/species/proc/spec_attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/obj/item/organ/limb/affecting, var/hit_area, var/intent, var/obj/item/organ/limb/target_limb, target_area, var/mob/living/carbon/human/H)
	// Allows you to put in item-specific reactions based on species
	if(user != src)
		user.do_attack_animation(H)
	if((user != H) && H.check_shields(I.force, "the [I.name]"))
		return 0

	if(I.attack_verb && I.attack_verb.len)
		H.visible_message("<span class='danger'>[H] has been [pick(I.attack_verb)] in the [hit_area] with [I] by [user]!</span>", \
						"<span class='userdanger'>[H] has been [pick(I.attack_verb)] in the [hit_area] with [I] by [user]!</span>")
	else if(I.force)
		H.visible_message("<span class='danger'>[H] has been attacked in the [hit_area] with [I] by [user]!</span>", \
						"<span class='userdanger'>[H] has been attacked in the [hit_area] with [I] by [user]!</span>")
	else
		return 0

	var/armor = H.run_armor_check(affecting, "melee", "<span class='warning'>Your armor has protected your [hit_area].</span>", "<span class='warning'>Your armor has softened a hit to your [hit_area].</span>")
	if(armor >= 100)	return 0
	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	apply_damage(I.force, I.damtype, affecting, armor, H)

	var/bloody = 0
	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.status == ORGAN_ORGANIC)
			I.add_blood(H)	//Make the weapon bloody, not the person.
			if(prob(I.force * 2))	//blood spatter!
				bloody = 1
				var/turf/location = H.loc
				if(istype(location, /turf/simulated))
					location.add_blood(H)
				if(get_dist(H, H) <= 1)	//people with TK won't get smeared with blood
					if(H.wear_suit)
						H.wear_suit.add_blood(H)
						H.update_inv_wear_suit(0)	//updates mob overlays to show the new blood (no refresh)
					else if(H.w_uniform)
						H.w_uniform.add_blood(H)
						H.update_inv_w_uniform(0)	//updates mob overlays to show the new blood (no refresh)
					if (H.gloves)
						var/obj/item/clothing/gloves/G = H.gloves
						G.add_blood(H)
					else
						H.add_blood(H)
						H.update_inv_gloves()	//updates on-mob overlays for bloody hands and/or bloody gloves


		switch(hit_area)
			if("head")	//Harder to score a stun but if you do it lasts a bit longer
				if(H.stat == CONSCIOUS && prob(I.force) && armor < 50)
					H.visible_message("<span class='danger'>[H] has been knocked unconscious!</span>", \
									"<span class='userdanger'>[H] has been knocked unconscious!</span>")
					H.apply_effect(20, PARALYZE, armor)
					if(H != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(H.mind)
						ticker.mode.remove_gangster(H.mind)

				if(bloody)	//Apply blood
					if(H.wear_mask)
						H.wear_mask.add_blood(H)
						H.update_inv_wear_mask(0)
					if(H.head)
						H.head.add_blood(H)
						H.update_inv_head(0)
					if(H.glasses && prob(33))
						H.glasses.add_blood(H)
						H.update_inv_glasses(0)

			if("chest")	//Easier to score a stun but lasts less time
				if(H.stat == CONSCIOUS && I.force && prob(I.force + 10))
					H.visible_message("<span class='danger'>[H] has been knocked down!</span>", \
									"<span class='userdanger'>[H] has been knocked down!</span>")
					H.apply_effect(5, WEAKEN, armor)

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_blood(H)
						H.update_inv_wear_suit(0)
					if(H.w_uniform)
						H.w_uniform.add_blood(H)
						H.update_inv_w_uniform(0)

		if(Iforce > 10 || Iforce >= 5 && prob(33))
			H.forcesay(hit_appends)	//forcesay checks stat already.
		return

/datum/species/proc/attacked_by(var/obj/item/I, var/mob/living/user, var/def_zone, var/mob/living/carbon/human/H)
	H.apply_damage(I.force, I.damtype)
	if(I.damtype == "brute")
		if(prob(33) && I.force && !(NOBLOOD in specflags))
			var/turf/location = H.loc
			if(istype(location, /turf/simulated))
				location.add_blood_floor(H)

	var/showname = "."
	if(user)
		showname = " by [user]!"
		if(user != src)
			user.do_attack_animation(H)
	if(!(user in viewers(I, null)))
		showname = "."

	if(I.attack_verb && I.attack_verb.len)
		H.visible_message("<span class='danger'>[H] has been [pick(I.attack_verb)] with [I][showname]</span>",
		"<span class='userdanger'>[H] has been [pick(I.attack_verb)] with [I][showname]</span>")
	else if(I.force)
		H.visible_message("<span class='danger'>[H] has been attacked with [I][showname]</span>",
		"<span class='userdanger'>[H] has been attacked with [I][showname]</span>")
	if(!showname && user)
		if(user.client)
			user << "<span class='danger'><B>You attack [H] with [I]. </B></span>"

	return

/datum/species/proc/apply_damage(var/damage, var/damagetype = BRUTE, var/def_zone = null, var/blocked, var/mob/living/carbon/human/H)
	blocked = (100-(blocked+armor))/100
	if(blocked <= 0)	return 0

	var/obj/item/organ/limb/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = H.get_organ(check_zone(def_zone))
	if(!organ)	return 0

	damage = (damage * blocked)

	switch(damagetype)
		if(BRUTE)
			H.damageoverlaytemp = 20
			if(organ.take_damage(damage*brutemod, 0))
				H.update_damage_overlays(0)
		if(BURN)
			H.damageoverlaytemp = 20
			if(organ.take_damage(0, damage*burnmod))
				H.update_damage_overlays(0)
		if(TOX)
			H.adjustToxLoss(damage * blocked)
		if(OXY)
			H.adjustOxyLoss(damage * blocked)
		if(CLONE)
			H.adjustCloneLoss(damage * blocked)
		if(STAMINA)
			H.adjustStaminaLoss(damage * blocked)

/datum/species/proc/on_hit(var/obj/item/projectile/proj_type, var/mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		if(/obj/item/projectile/energy/florayield)
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	return


/datum/species/proc/handle_environment(datum/gas_mixture/environment, var/mob/living/carbon/human/H)
	if(!environment)
		return

	var/loc_temp = H.get_temperature(environment)
	//world << "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Thermal protection: [get_thermal_protection()] - Fire protection: [thermal_protection + add_fire_protection(loc_temp)] - Heat capacity: [environment_heat_capacity] - Location: [loc] - src: [src]"

	//Body temperature is adjusted in two steps. Firstly your body tries to stabilize itself a bit.
	if(H.stat != 2)
		H.stabilize_temperature_from_calories()

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!H.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < H.bodytemperature)
			//Place is colder than we are
			var/thermal_protection = H.get_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				H.bodytemperature += min((1-thermal_protection) * ((loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR), BODYTEMP_COOLING_MAX)
		else
			//Place is hotter than we are
			var/thermal_protection = H.get_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				H.bodytemperature += min((1-thermal_protection) * ((loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR), BODYTEMP_HEATING_MAX)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !(HEATRES in specflags))
		//Body temperature is too hot.
		H.fire_alert = max(H.fire_alert, 1)
		switch(H.bodytemperature)
			if(360 to 400)
				H.apply_damage(HEAT_DAMAGE_LEVEL_1*heatmod, BURN)
				H.fire_alert = max(H.fire_alert, 2)
			if(400 to 460)
				H.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
				H.fire_alert = max(H.fire_alert, 2)
			if(460 to INFINITY)
				if(H.on_fire)
					H.apply_damage(HEAT_DAMAGE_LEVEL_3*heatmod, BURN)
					H.fire_alert = max(H.fire_alert, 2)
				else
					H.apply_damage(HEAT_DAMAGE_LEVEL_2*heatmod, BURN)
					H.fire_alert = max(H.fire_alert, 2)

	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !(COLDRES in specflags))
		H.fire_alert = max(H.fire_alert, 1)
		if(!istype(H.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			switch(H.bodytemperature)
				if(200 to 260)
					H.apply_damage(COLD_DAMAGE_LEVEL_1*coldmod, BURN)
					H.fire_alert = max(H.fire_alert, 1)
				if(120 to 200)
					H.apply_damage(COLD_DAMAGE_LEVEL_2*coldmod, BURN)
					H.fire_alert = max(H.fire_alert, 1)
				if(-INFINITY to 120)
					H.apply_damage(COLD_DAMAGE_LEVEL_3*coldmod, BURN)
					H.fire_alert = max(H.fire_alert, 1)

	// Account for massive pressure differences.  Done by Polymorph
	// Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!(HEATRES in specflags))
				H.adjustBruteLoss( min( ( (adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
				H.pressure_alert = 2
			else
				H.pressure_alert = 1
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			H.pressure_alert = -1
		else
			if((COLD_RESISTANCE in H.mutations) || (COLDRES in specflags))
				H.pressure_alert = -1
			else
				H.adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				H.pressure_alert = -2

	return

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(var/mob/living/carbon/human/H)
	if((HEATRES in specflags) || (NOFIRE in specflags))
		return
	if(H.fire_stacks < 0)
		H.fire_stacks++ //If we've doused ourselves in water to avoid fire, dry off slowly
		H.fire_stacks = min(0, H.fire_stacks)//So we dry ourselves back to default, nonflammable.
	if(!H.on_fire)
		return
	var/datum/gas_mixture/G = H.loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.oxygen < 1)
		ExtinguishMob(H) //If there's no oxygen in the tile we're on, put out the fire
		return
	var/turf/location = get_turf(H)
	location.hotspot_expose(700, 50, 1)

/datum/species/proc/IgniteMob(var/mob/living/carbon/human/H)
	if(H.fire_stacks > 0 && !H.on_fire && !(HEATRES in specflags) && !(NOFIRE in specflags))
		H.on_fire = 1
		H.AddLuminosity(3)
		H.update_fire()

/datum/species/proc/ExtinguishMob(var/mob/living/carbon/human/H)
	if(H.on_fire)
		H.on_fire = 0
		H.fire_stacks = 0
		H.AddLuminosity(-3)
		H.update_fire()

#undef SPECIES_LAYER
#undef BODY_LAYER
#undef HAIR_LAYER

#undef HUMAN_MAX_OXYLOSS
#undef HUMAN_CRIT_MAX_OXYLOSS

#undef HEAT_DAMAGE_LEVEL_1
#undef HEAT_DAMAGE_LEVEL_2
#undef HEAT_DAMAGE_LEVEL_3

#undef COLD_DAMAGE_LEVEL_1
#undef COLD_DAMAGE_LEVEL_2
#undef COLD_DAMAGE_LEVEL_3

#undef HEAT_GAS_DAMAGE_LEVEL_1
#undef HEAT_GAS_DAMAGE_LEVEL_2
#undef HEAT_GAS_DAMAGE_LEVEL_3

#undef COLD_GAS_DAMAGE_LEVEL_1
#undef COLD_GAS_DAMAGE_LEVEL_2
#undef COLD_GAS_DAMAGE_LEVEL_3

#undef TINT_IMPAIR
#undef TINT_BLIND
