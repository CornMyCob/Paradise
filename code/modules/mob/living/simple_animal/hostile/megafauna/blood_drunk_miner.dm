#define MINER_DASH_RANGE 4

/*

BLOOD-DRUNK MINER

Effectively a highly aggressive miner, the blood-drunk miner has very few attacks but compensates by being highly aggressive.

The blood-drunk miner's attacks are as follows
- If not in KA range, it will rapidly dash at its target
- If in KA range, it will fire its kinetic accelerator
- If in melee range, will rapidly attack, akin to an actual player
- After any of these attacks, may transform its cleaving saw:
	Untransformed, it attacks very rapidly for smaller amounts of damage
	Transformed, it attacks at normal speed for higher damage and cleaves enemies hit

When the blood-drunk miner dies, it leaves behind the cleaving saw it was using and its kinetic accelerator.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner
	name = "blood-drunk miner"
	desc = "A miner destined to wander forever, engaged in an endless hunt."
	health = 900
	maxHealth = 900
	icon_state = "miner"
	icon_living = "miner"
	icon = 'icons/mob/alienqueen.dmi'
	light_color = "#E4C7C5"
	speak_emote = list("roars")
	speed = 1
	move_to_delay = 3
	projectiletype = /obj/item/projectile/kinetic/miner
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	ranged = 1
	ranged_cooldown_time = 16
	pixel_x = -16
	loot = list(/obj/item/melee/energy/cleaving_saw, /obj/item/gun/energy/kinetic_accelerator)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/melee/energy/cleaving_saw/miner_saw
	var/time_until_next_transform = 0
	var/dashing = FALSE
	var/dash_cooldown = 15
	var/guidance = FALSE
	deathmessage = "falls to the ground, decaying into glowing particles."
	death_sound = "bodyfall"

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/New()
	..()
	internal_gps = new/obj/item/gps/internal/miner(src)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance
	guidance = TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter/AttackingTarget()
	. = ..()
	if(. && prob(12))
		INVOKE_ASYNC(src, .proc/dash)

/obj/item/melee/energy/cleaving_saw/miner //nerfed saw because it is very murdery
	force = 6
	force_on = 10

/obj/item/projectile/kinetic/miner
	damage = 20
	speed = 0.9
	icon_state = "ka_tracer"
	range = MINER_DASH_RANGE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Initialize()
	. = ..()
	miner_saw = new(src)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	var/adjustment_amount = amount * 0.1
	if(world.time + adjustment_amount > next_move)
		changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	. = ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/death()
	if(health > 0)
		return
	new /obj/effect/temp_visual/dir_setting/miner_death(loc, dir)
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Move(atom/newloc)
	if(dashing || (newloc && newloc.z == z && (islava(newloc) || ischasm(newloc)))) //we're not stupid!
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/ex_act(severity, target)
	if(dash())
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/AttackingTarget()
	if(QDELETED(target))
		return
	if(next_move > world.time || !Adjacent(target)) //some cheating
		INVOKE_ASYNC(src, .proc/quick_attack_loop)
		return
	face_atom(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			visible_message("<span class='danger'>[src] butchers [L]!</span>",
			"<span class='userdanger'>You butcher [L], restoring your health!</span>")
			if(!is_station_level(z) || client) //NPC monsters won't heal while on station
				if(guidance)
					adjustHealth(-L.maxHealth)
				else
					adjustHealth(-(L.maxHealth * 0.5))
			L.gib()
			return TRUE
	changeNext_move(CLICK_CD_MELEE)
	miner_saw.melee_attack_chain(src, target)
	if(guidance)
		adjustHealth(-2)
	transform_weapon()
	INVOKE_ASYNC(src, .proc/quick_attack_loop)
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(A))
		used_item = miner_saw
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		wander = TRUE
		transform_weapon()
		INVOKE_ASYNC(src, .proc/quick_attack_loop)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/OpenFire()
	Goto(target, move_to_delay, minimum_distance)
	if(get_dist(src, target) > MINER_DASH_RANGE && dash_cooldown <= world.time)
		INVOKE_ASYNC(src, .proc/dash, target)
	else
		shoot_ka()
	transform_weapon()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/shoot_ka()
	if(ranged_cooldown <= world.time && get_dist(src, target) <= MINER_DASH_RANGE && !Adjacent(target))
		ranged_cooldown = world.time + ranged_cooldown_time
		visible_message("<span class='danger'>[src] fires the proto-kinetic accelerator!</span>")
		face_atom(target)
		new /obj/effect/temp_visual/dir_setting/firing_effect(loc, dir)
		Shoot(target)
		changeNext_move(CLICK_CD_RANGE)

//I'm still of the belief that this entire proc needs to be wiped from existence.
//  do not take my touching of it to be endorsement of it. ~mso
/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/quick_attack_loop()
	while(!QDELETED(target) && next_move <= world.time) //this is done this way because next_move can change to be sooner while we sleep.
		stoplag(1)
	sleep((next_move - world.time) * 1.5) //but don't ask me what the fuck this is about
	if(QDELETED(target))
		return
	if(dashing || next_move > world.time || !Adjacent(target))
		if(dashing && next_move <= world.time)
			next_move = world.time + 1
		INVOKE_ASYNC(src, .proc/quick_attack_loop) //lets try that again.
		return
	AttackingTarget()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/dash(atom/dash_target)
	if(world.time < dash_cooldown)
		return
	var/list/accessable_turfs = list()
	var/self_dist_to_target = 0
	var/turf/own_turf = get_turf(src)
	if(!QDELETED(dash_target))
		self_dist_to_target += get_dist(dash_target, own_turf)
	for(var/turf/simulated/O in RANGE_TURFS(MINER_DASH_RANGE, own_turf))
		var/turf_dist_to_target = 0
		if(!QDELETED(dash_target))
			turf_dist_to_target += get_dist(dash_target, O)
		if(get_dist(src, O) >= MINER_DASH_RANGE && turf_dist_to_target <= self_dist_to_target && !islava(O) && !ischasm(O))
			var/valid = TRUE
			for(var/turf/T in getline(own_turf, O))
				if(is_blocked_turf(T, TRUE))
					valid = FALSE
					continue
			if(valid)
				accessable_turfs[O] = turf_dist_to_target
	var/turf/target_turf
	if(!QDELETED(dash_target))
		var/closest_dist = MINER_DASH_RANGE
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] < closest_dist)
				closest_dist = accessable_turfs[t]
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] != closest_dist)
				accessable_turfs -= t
	if(!LAZYLEN(accessable_turfs))
		return
	dash_cooldown = world.time + initial(dash_cooldown)
	target_turf = pick(accessable_turfs)
	var/turf/step_back_turf = get_step(target_turf, get_cardinal_dir(target_turf, own_turf))
	var/turf/step_forward_turf = get_step(own_turf, get_cardinal_dir(own_turf, target_turf))
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_back_turf)
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_forward_turf)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/D = new (own_turf, src)
	forceMove(step_back_turf)
	playsound(own_turf, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	dashing = TRUE
	alpha = 0
	animate(src, alpha = 255, time = 5)
	sleep(2)
	D.forceMove(step_forward_turf)
	forceMove(target_turf)
	playsound(target_turf, 'sound/weapons/punchmiss.ogg', 40, 1, -1)
	sleep(1)
	dashing = FALSE
	shoot_ka()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/transform_weapon()
	if(time_until_next_transform <= world.time)
		miner_saw.transform_cooldown = 0
		miner_saw.transform_weapon(src, TRUE)
		icon_state = "miner[miner_saw.active ? "_transformed":""]"
		icon_living = "miner[miner_saw.active ? "_transformed":""]"
		time_until_next_transform = world.time + rand(50, 100)

/obj/effect/temp_visual/dir_setting/miner_death
	icon_state = "miner_death"
	duration = 15

/obj/effect/temp_visual/dir_setting/miner_death/Initialize(mapload, set_dir)
	. = ..()
	INVOKE_ASYNC(src, .proc/fade_out)

/obj/effect/temp_visual/dir_setting/miner_death/proc/fade_out()
	var/matrix/M = new
	M.Turn(pick(90, 270))
	var/final_dir = dir
	if(dir & (EAST|WEST)) //Facing east or west
		final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	animate(src, transform = M, pixel_y = -6, dir = final_dir, time = 2, easing = EASE_IN|EASE_OUT)
	sleep(5)
	animate(src, color = list("#A7A19E", "#A7A19E", "#A7A19E", list(0, 0, 0)), time = 10, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(4)
	animate(src, alpha = 0, time = 6, easing = EASE_OUT, flags = ANIMATION_PARALLEL)

/obj/item/gps/internal/miner
	icon_state = null
	gpstag = "Resonant Signal"
	desc = "The sweet blood, oh, it sings to me."
	invisibility = 100

#undef MINER_DASH_RANGE

///Bosses

//Miniboss Miner

/obj/item/melee/energy/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	force = 12
	force_on = 20 //force when active
	throwforce = 20
	throwforce_on = 20
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	icon_state = "cleaving_saw"
	icon_state_on = "cleaving_saw_open"
	slot_flags = SLOT_BELT
	var/attack_verb_off = list("attacked", "sawed", "sliced", "torn", "ripped", "diced", "cut")
	attack_verb_on = list("cleaved", "swiped", "slashed", "chopped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharp = 1
	faction_bonus_force = 30
	nemesis_factions = list("mining", "boss")
	var/transform_cooldown
	var/swiping = FALSE

/obj/item/melee/energy/cleaving_saw/proc/nemesis_effects(mob/living/user, mob/living/target)
	var/datum/status_effect/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	if(!B)
		if(!active) //This isn't in the above if-check so that the else doesn't care about active
			target.apply_status_effect(STATUS_EFFECT_SAWBLEED)
	else
		B.add_bleed(B.bleed_buildup)

/obj/item/melee/energy/cleaving_saw/attack_self(mob/living/carbon/user)
	if(user.disabilities & CLUMSY && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_organ_damage(10,10)
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/bladeslice.ogg'
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		if(!item_color)
			icon_state = icon_state_on
			set_light(brightness_on)
		else
			icon_state = "sword[item_color]"
			set_light(brightness_on, l_color=colormap[item_color])
		w_class = w_class_on
		playsound(user, 'sound/magic/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))
		to_chat(user, "<span class='notice'>You open [src]. It will now cleave enemies in a wide arc and deal additional damage to fauna.</span>")
	else
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_on.len)
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/magic/fellowship_armory.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		set_light(0)
		to_chat(user, "<span class='notice'>You close [src]. It will now attack rapidly and cause fauna to bleed.</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/item/melee/energy/cleaving_saw/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It is [active ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].<br>\
	Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.<br>\
	Transforming it immediately after an attack causes the next attack to come out faster.</span>")

/obj/item/melee/energy/cleaving_saw/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is [active ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/melee/energy/cleaving_saw/proc/transform_weapon(mob/living/user, supress_message_text)
	if(transform_cooldown > world.time)
		return FALSE
	. = ..()
	if(.)
		transform_cooldown = world.time + (CLICK_CD_MELEE * 0.5)
		user.changeNext_move(CLICK_CD_MELEE * 0.25)

/obj/item/melee/energy/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(!active)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/energy/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	if(!active || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!active)
			faction_bonus_force = 0
		..()
		if(!active)
			faction_bonus_force = initial(faction_bonus_force)
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
		for(var/i in cleaving_saw_cleave_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/mob/living/L in T)
				if(user.Adjacent(L) && L.density)
					melee_attack_chain(user, L)
		swiping = FALSE
