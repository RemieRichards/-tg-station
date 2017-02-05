/*

NECROPOLIS CHAMPION

The Necropolis Champion is the forward scout from the Necropolis proper, they spawn riding an Ash Drake (with no loot for the drake)
Defeating the drake forces you into combat with the Champion personally.

The Champion is wearing incredibly tough armour (full 90s), but has a crack in the back of their armour,
melee attacks to this crack deal vastly more damage (this is the intended way to fight them)

Depending on how you kill the Champion, there are two outcomes:

Honourable fight (Melee attacks) - The Champion collapses into dust, leaving their armour to the victor
there is also a 50% chance to drop an Ash Drake loot chest

Dishonourable fight (Non-Melee attacks (JUST ONE DISQUALIFIES YOU FROM HONOUR!)) - The Champion collapses into dust, leaving their armour empty.
The killer also collapses into dust, Their soul flies into the armour and reforms, the player is now the Necropolis Champion...
The Player champion cannot leave Lavaland (except for the Necropolis, when it's eventually added (kor pls))

Difficulty: Hard (Ash Drake Medium + Champ Medium = Overall Hard)

*/

/mob/living/simple_animal/hostile/megafauna/necropolis_champion
	name = "necropolis champion"
	desc = "The champion of the necropolis, their armour is tough and their weapon bloodthirsty"
	health = 2000
	maxHealth = 2000
	attacktext = "stabs"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	/*
	icon = 'icons/mob/lavaland/necropolis_champion.dmi'
	icon_state = "necropolis_champ" //way to go champ
	icon_living = "necropolis_champ"
	*/
	icon = 'icons/mob/animal.dmi'
	icon_state = "clown"
	icon_living = "clown"


	friendly = "respectfully nods to"
	armour_penetration = 30
	melee_damage_lower = 30
	melee_damage_upper = 45
	//armor = list("melee" = 90, "bullet" = 90, "laser" = 90, "energy" = 900, "bomb" = 90, "bio" = 90, "rad" = 90, "fire" = 90, "acid" = 90)
	damage_coeff = list(BRUTE = 0.1, BURN = 0.1, TOX = 0.1, CLONE = 0.1, STAMINA = 0, OXY = 0.1) //acts as 90% "armour"
	mob_size = MOB_SIZE_HUMAN
	layer = LARGE_MOB_LAYER-0.2
	mouse_opacity = 1
	environment_smash = 1
	var/champ_weakpoint_dmg_multiplier = 12
	var/ability_cooldown = 0
	var/lunge_wait = 30
	var/spin_wait = 60
	var/stuck_time = 50
	var/spinning = FALSE
	var/list/spinning_blades
	var/stuck_timer_id
	var/list/dishonourable
	var/mob/living/last_attacker


//The actual boss that spawns, the above is just for the second phase
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/drakerider/New()
	..()

	var/mob/living/simple_animal/hostile/megafauna/dragon/Drake = new(loc)
	Drake.loot = list() //None for you
	Drake.score_type = null
	Drake.medal_type = null
	Drake.buckle_mob(src, TRUE)


//Where dishonourable killers end up
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/player
	AIStatus = AI_OFF

/mob/living/simple_animal/hostile/megafauna/necropolis_champion/player/AltClickOn(atom/A)
	if(!A)
		return
	if(!can_perform_action())
		src << "<span class='warning'>You need to wait between lunges!</span>"
		return
	lunge(A)


//Weakspot
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(user.zone_selected != "chest")
		return ..()
	var/multiplier = 1
	if(get_turf(user) == get_step(src, turn(dir, 180))) //Behind the champion
		multiplier = champ_weakpoint_dmg_multiplier

	last_attacker = user

	if(stuck_timer_id)
		get_unstuck()

	apply_damage(I.force * multiplier, I.damtype, def_zone)

	var/message_verb = DEFAULTPICK(I.attack_verb, "attacked")
	var/attack_message = "[src] has been [message_verb] with [I]."
	if(user)
		user.do_attack_animation(src)
		if(user in viewers(src, null))
			attack_message = "[user] has [message_verb] [src] with [I]!"
	if(message_verb)
		visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message]</span>", null, COMBAT_MESSAGE_RANGE)

	if(multiplier > 1)
		user << "<span class='notice'>You hit [src] in their armour's weakpoint!</span>"
	return TRUE



/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/can_perform_action()
	if(throwing || spinning || (ability_cooldown > world.time))
		return FALSE
	return TRUE



//"AI"
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/handle_automated_action()
	. = ..()
	if(.)
		if(buckled) //Drakeriding
			setDir(buckled.dir)
			if(buckled.dir == NORTH)
				layer = LARGE_MOB_LAYER + 0.2
			else
				layer = LARGE_MOB_LAYER - 0.2
		else
			if(target && can_perform_action())
				if(prob(30))
					lunge()
				else if(prob(30))
					spin()


//Lunge Attack
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/lunge(atom/AT)
	var/Target = AT || target
	var/turf/T = get_turf(Target)
	if(!T || T == loc)
		return
	visible_message("<span class='warning'>[src] lunges at [Target]!</span>")
	ability_cooldown = world.time + lunge_wait
	var/obj/effect/overlay/temp/dragon_swoop/DS = PoolOrNew(/obj/effect/overlay/temp/dragon_swoop, T)
	DS.transform *= 0.5
	walk(src, 0)
	setDir(get_dir(src, T))
	throw_at(T, get_dist(src, T), 3, src, 0, 1)


//Getting stuck in things via lunge
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/throw_impact(atom/hit_atom)
	..()
	if(isturf(hit_atom) && hit_atom.density)
		get_stuck(hit_atom)


/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/get_stuck(turf/T)
	AIStatus = AI_OFF
	walk(src, 0)
	if(stuck_timer_id)
		deltimer(stuck_timer_id)
	stuck_timer_id = addtimer(src, "get_unstuck", stuck_time, TIMER_NORMAL)
	visible_message("<span class='warning'>[src] gets their weapon lodged in [T]!</span>")


/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/get_unstuck()
	AIStatus = AI_ON
	if(stuck_timer_id)
		deltimer(stuck_timer_id)
	stuck_timer_id = 0
	visible_message("<span class='warning'>[src] breaks free!</span>")


//Spin Attack
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/spin()
	if(spinning)
		return

	//Blades
	if(!spinning_blades)
		spinning_blades = list()
		for(var/ddir in cardinal)
			var/obj/item/projectile/colossus/C = new(get_step(src, ddir))
			C.animate_movement = SLIDE_STEPS
			spinning_blades += C
			sleep(2.5)
			C.orbit(src, radius = 16, clockwise = TRUE, rotation_speed = 10, pre_rotation = FALSE, lockinorbit = TRUE)
	else
		var/list/cardinalcopy = cardinal.Copy()
		for(var/a in spinning_blades)
			var/atom/movable/AM = a
			AM.forceMove(get_step(src, pick_n_take(cardinalcopy)))
			sleep(2.5)
			AM.orbit(src, radius = 16, clockwise = TRUE, rotation_speed = 10, pre_rotation = FALSE, lockinorbit = TRUE)

	visible_message("<span class='warning'>[src] spins up a whirlwind of blades!</span>")
	spinning = TRUE
	ability_cooldown = world.time + spin_wait
	addtimer(src, "stop_spinning", spin_wait * 2, TIMER_UNIQUE)
	var/dir_index = 1
	setDir(cardinal[1])
	while(spinning)
		dir_index = dir_index % cardinal.len + 1
		setDir(cardinal[dir_index])
		sleep(1)
		CHECK_TICK

	//Blade cleanup
	for(var/a in spinning_blades)
		var/atom/movable/AM = a
		AM.stop_orbit()
		AM.loc = null

	spinning = FALSE


/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/stop_spinning()
	spinning = FALSE



//"Honour"
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/bullet_act(obj/item/projectile/P)
	if(P && P.firer && P.damage && (P.damtype == BRUTE || P.damtype == BURN)) //this locks them out of the "good win" so let's be extra sure
		LAZYINITLIST(dishonourable)
		dishonourable[P.firer] = TRUE
		last_attacker = P.firer
	return ..()


//Justice for the dishonourable
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/death(gibbed)
	if(last_attacker && dishonourable)
		if(dishonourable[last_attacker])
			bad_kill()
		else
			good_kill()
	else
		good_kill()
	qdel(src)



/mob/living/simple_animal/hostile/megafauna/necropolis_champion/EscapeConfinement()
	if(buckled && !ismob(buckled)) //Dragon riding
		buckled.attack_animal(src)
	if(!isturf(targets_from.loc) && targets_from.loc != null)
		var/atom/A = get_turf(targets_from)
		A.attack_animal(src)



//Reward
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/good_kill()
	spawn_dust()

	var/turf/T = get_turf(src)

	//new /obj/item/clothing/suit/necropolis_champion(T)
	//new /obj/item/clothing/head/necropolis_champion(T)

	grant_achievement("necropolis_champion" ,"necropolis_champion")


	if(prob(50))
		new /obj/structure/closet/crate/necropolis/dragon(T)

	visible_message("<span class='notice'>[src] returns to the dust...</span>")


//Punishment
/mob/living/simple_animal/hostile/megafauna/necropolis_champion/proc/bad_kill()
	spawn_dust()

	if(last_attacker)
		visible_message("<span class='notice'>[src] returns to the dust...</span> <span class='warning'>but at what cost?</span>")

		var/mob/living/simple_animal/hostile/megafauna/necropolis_champion/player/Prison = new(get_turf(src))
		if(last_attacker.mind)
			last_attacker.mind.transfer_to(Prison)
		else
			Prison.ckey = last_attacker.ckey

		last_attacker.dust()

	else
		visible_message("<span class='notice'>[src] returns to the dust...</span>")
