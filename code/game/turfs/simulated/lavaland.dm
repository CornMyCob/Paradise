
/**********************Asteroid**************************/

/turf/simulated/floor/plating/asteroid/lavaland //floor piece
	oxygen = 14
	nitrogen = 23
	temperature = 300
	gender = PLURAL
	name = "volcanic floor"
	icon = 'icons/turf/mining.dmi'
	icon_state = "basalt"
	var/environment_type = "basalt"
	var/floor_variance = 20 //probability floor has a different icon state
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/
	var/dug
	thermal_conductivity = 0

/turf/simulated/floor/plating/asteroid/lavaland/Initialize()
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(0,10)]"

/turf/simulated/floor/plating/asteroid/lavaland/proc/getDug()
	new digResult(src, 5)
	icon_plating = "basalt_dug"
	icon_state = "basalt_dug"
	dug = TRUE

/turf/simulated/floor/plating/asteroid/lavaland/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")

/turf/simulated/floor/plating/asteroid/lavaland/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/simulated/floor/plating/asteroid/lavaland/burn_tile()
	return

/turf/simulated/floor/plating/asteroid/lavaland/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/simulated/floor/plating/asteroid/lavaland/MakeDry()
	return

/turf/simulated/floor/plating/asteroid/lavaland/attackby(obj/item/W, mob/user, params)
	if(!W || !user)
		return 0

	if(istype(W, /obj/item/shovel) || istype(W, /obj/item/pickaxe))
		var/turf/T = get_turf(user)
		if(!istype(T))
			return

		if(dug)
			to_chat(user, "<span class='warning'>This area has already been dug!</span>")
			return

		to_chat(user, "<span class='notice'>You start digging...</span>")
		if((istype(W, /obj/item/shovel)))
			if(do_after(user, 20 * W.toolspeed, target = src))
				to_chat(user, "<span class='notice'>You dig a hole.</span>")
				getDug()
				return
		if((istype(W, /obj/item/pickaxe)))
			var/obj/item/pickaxe/P = W
			if(do_after(user, P.digspeed, target = src))
				to_chat(user, "<span class='notice'>You dig a hole.</span>")
				getDug()
				return

/turf/simulated/floor/plating/asteroid/lavaland/basalt
	name = "volcanic floor"
	floor_variance = 15
	digResult = /obj/item/stack/ore/glass/*/lavaland/basalt*/ // FIX THIS LATER AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

/turf/simulated/floor/plating/asteroid/lavaland/basalt/Initialize()
	. = ..()
	set_basalt_light(src)

/turf/simulated/floor/plating/asteroid/lavaland/getDug()
	set_light(0)
	return ..()

/proc/set_basalt_light(turf/simulated/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_ORANGE) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_ORANGE) //barely anything!

// Snow, however that works
/turf/simulated/floor/plating/asteroid/lavaland/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	icon_plating = "snow"
	oxygen = 22
	nitrogen = 82
	temperature = 180
	slowdown = 2
	environment_type = "snow"
	burnt_states = list("snow_dug")
	digResult = /obj/item/stack/sheet/mineral //snow

/turf/simulated/floor/plating/asteroid/lavaland/snow/burn_tile()
	if(!burnt)
		visible_message("<span class='danger'>[src] melts away!.</span>")
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/simulated/floor/plating/asteroid/lavaland/snow/ice
	name = "icy snow"
	desc = "Looks colder."
	oxygen = 0
	nitrogen = 82
	toxins = 24
	temperature = 120
	floor_variance = 0
	icon_state = "snow-ice"
	icon_plating = "snow-ice"
	environment_type = "snow_cavern"

/turf/simulated/floor/plating/asteroid/lavaland/snow/ice/burn_tile()
	return FALSE

/turf/simulated/floor/plating/asteroid/lavaland/snow/airless
	oxygen = 0
	nitrogen = 0
	temperature = 2.7

/turf/simulated/floor/plating/asteroid/lavaland/snow/temperatre
	oxygen = 22
	nitrogen = 82
	temperature = 255.37

// LAVA ITSELF
/turf/simulated/floor/plating/asteroid/lavaland/lava
	name = "lava"
	gender = PLURAL //"That's some lava."
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/simulated/floor/plating/asteroid/lavaland/lava)
	slowdown = 2
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_ORANGE

/turf/simulated/floor/plating/asteroid/lavaland/lava/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/asteroid/lavaland/lava/Entered(mob/living/M)
	if(istype(M))
		// Dont burn them if its got tiles
		if(locate(/obj/structure/stone_tile) in get_turf(M))
			return
		// Dont burn them if they are lava immune
		for(var/immunity in M.weather_immunities)
			if(immunity == "lava")
				return
		// Burn the fucker
		M.apply_damage(25, BURN)
		M.adjust_fire_stacks(10) // its fockin' lava mate
		M.IgniteMob()

/turf/simulated/floor/plating/asteroid/lavaland/lava/singularity_act()
	return

/turf/simulated/floor/plating/asteroid/lavaland/lava/singularity_pull(S, current_size)
	return

/turf/simulated/floor/plating/asteroid/lavaland/lava/proc/is_safe()
	//if anything matching this typecache is found in the lava, we don't burn things
	var/static/list/lava_safeties_typecache = typecacheof(list(/turf/simulated/floor/plating/airless/catwalk, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, lava_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/turf/simulated/floor/plating/asteroid/lavaland/lava/smooth
	name = "lava"
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE | SMOOTH_BORDER
	canSmoothWith = list(/turf/simulated/floor/plating/asteroid/lavaland/lava/smooth)

// Chasms

/turf/simulated/floor/plating/asteroid/lavaland/chasm
	name = "chasm"
	desc = "Watch your step."
	smooth = SMOOTH_TRUE | SMOOTH_BORDER | SMOOTH_MORE
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "smooth"
	canSmoothWith = list(/turf/simulated/floor/plating/asteroid/lavaland/chasm)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	var/static/list/falling_atoms = list() //Atoms currently falling into the chasm
	var/static/list/forbidden_types = typecacheof(list(/obj/effect/portal, /obj/singularity, /obj/structure/stone_tile, /obj/item/projectile, /obj/effect/temp_visual, /obj/effect/light_emitter/tendril, /obj/effect/collapse))
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = 1

/turf/simulated/floor/plating/asteroid/lavaland/chasm/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0)
	return

/turf/simulated/floor/plating/asteroid/lavaland/chasm/MakeDry(wet_setting = TURF_WET_WATER)
	return

/turf/simulated/floor/plating/asteroid/lavaland/chasm/Entered(atom/movable/AM)
	..()
	drop_stuff(AM)

/turf/simulated/floor/plating/asteroid/lavaland/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(!L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				ReplaceWithLattice()
			else
				to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
			return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				ChangeTurf(/turf/simulated/floor/plating)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/simulated/floor/plating/asteroid/lavaland/chasm/proc/is_safe()
	//if anything matching this typecache is found in the chasm, we don't drop things
	var/static/list/chasm_safeties_typecache = typecacheof(list(/turf/simulated/floor/plating/airless/catwalk, /obj/structure/stone_tile))
	var/list/found_safeties = typecache_filter_list(contents, chasm_safeties_typecache)
	for(var/obj/structure/stone_tile/S in found_safeties)
		if(S.fallen)
			LAZYREMOVE(found_safeties, S)
	return LAZYLEN(found_safeties)

/turf/simulated/floor/plating/asteroid/lavaland/chasm/proc/drop_stuff(AM)
	. = 0
	if(is_safe())
		return FALSE
	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(droppable(thing))
			. = 1
			INVOKE_ASYNC(src, .proc/drop, thing)

/turf/simulated/floor/plating/asteroid/lavaland/chasm/proc/droppable(atom/movable/AM)
	if(falling_atoms[AM])
		return FALSE
	if(!isliving(AM) && !isobj(AM))
		return FALSE
	if(is_type_in_typecache(AM, forbidden_types) || AM.throwing)
		return FALSE
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.belt, /obj/item/wormhole_jaunter))
			var/obj/item/wormhole_jaunter/J = H.belt
			//To freak out any bystanders
			visible_message("<span class='boldwarning'>[H] falls into [src]!</span>")
			J.chasm_react(H)
			return FALSE
	return TRUE

/turf/simulated/floor/plating/asteroid/lavaland/chasm/proc/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	falling_atoms[AM] = TRUE
	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>GAH! Ah... where are you?</span>")
		T.visible_message("<span class='boldwarning'>[AM] falls from above!</span>")
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Weaken(20) // Same as a stunbaton
			L.adjustBruteLoss(30)
	falling_atoms -= AM

/turf/simulated/floor/plating/asteroid/lavaland/chasm/straight_down/Initialize()
	. = ..()
	drop_x = x
	drop_y = y
	drop_z = z - 1
	var/turf/T = locate(drop_x, drop_y, drop_z)
	T.visible_message("<span class='boldwarning'>The ceiling gives way!</span>")
	playsound(T, 'sound/effects/break_stone.ogg', 50, 1)

/turf/simulated/floor/plating/asteroid/lavaland/chasm/straight_down
	light_range = 1.9 //slightly less range than lava
	light_power = 0.65 //less bright, too
	light_color = LIGHT_COLOR_ORANGE //let's just say you're falling into lava, that makes sense right

/turf/simulated/floor/plating/asteroid/lavaland/chasm/straight_down/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	falling_atoms[AM] = TRUE
	AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall \
	into the enveloping dark.</span>")
	if(isliving(AM))
		var/mob/living/L = AM
		L.notransform = TRUE
		L.Stun(200)
		L.resting = TRUE
	var/oldtransform = AM.transform
	var/oldcolor = AM.color
	var/oldalpha = AM.alpha
	animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return
		AM.pixel_y--
		sleep(2)

	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return

	if(istype(AM, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/S = AM
		qdel(S.mmi)

	falling_atoms -= AM

	qdel(AM)

	if(AM && !QDELETED(AM))	//It's indestructible
		visible_message("<span class='boldwarning'>[src] spits out the [AM]!</span>")
		AM.alpha = oldalpha
		AM.color = oldcolor
		AM.transform = oldtransform
		AM.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))

/turf/simulated/floor/plating/asteroid/lavaland/chasm/CanPass(atom/movable/mover, turf/target)
	return 1
