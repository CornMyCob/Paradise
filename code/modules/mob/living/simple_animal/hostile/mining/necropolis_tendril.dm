//Necropolis Tendrils, which spawn lavaland monsters and break into a chasm when killed
/obj/effect/light_emitter/tendril
	light_color = LIGHT_COLOR_ORANGE

/mob/living/simple_animal/hostile/spawner/lavaland
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground. Terrible monsters are pouring out of it."
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	icon_living = "tendril"
	icon_dead = "tendril"
	faction = list("mining")
	weather_immunities = list("lava","ash")
	health = 250
	maxHealth = 250
	max_mobs = 3
	spawn_time = 300 //30 seconds default
	mob_type = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	spawn_text = "emerges from"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	loot = list(/obj/effect/collapse, /obj/structure/closet/crate/necropolis/tendril)
	del_on_death = 1
	var/gps = null
	var/obj/effect/light_emitter/tendril/emitted_light

/mob/living/simple_animal/hostile/spawner/lavaland/goliath
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril

/mob/living/simple_animal/hostile/spawner/lavaland/legion
	mob_type = /mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril

/mob/living/simple_animal/hostile/spawner/lavaland/Initialize()
	. = ..()
	emitted_light = new(loc)
	for(var/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/simulated/mineral/lavaland/M = F
			M.gets_drilled(null, 2)
	gps = new /obj/item/gps/internal(src)

/mob/living/simple_animal/hostile/spawner/lavaland/Destroy()
	QDEL_NULL(emitted_light)
	QDEL_NULL(gps)
	return ..()

/obj/effect/collapse
	name = "collapsing necropolis tendril"
	desc = "Get clear!"
	layer = TABLE_LAYER
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	anchored = TRUE
	density = TRUE
	var/obj/effect/light_emitter/tendril/emitted_light

/obj/effect/collapse/Initialize()
	. = ..()
	emitted_light = new(loc)
	visible_message("<span class='boldannounce'>The tendril writhes in fury as the earth around it begins to crack and break apart! Get back!</span>")
	visible_message("<span class='warning'>Something falls free of the tendril!</span>")
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
	addtimer(CALLBACK(src, .proc/collapse), 50)

/obj/effect/collapse/Destroy()
	QDEL_NULL(emitted_light)
	return ..()

/obj/effect/collapse/proc/collapse()
	for(var/mob/M in range(7,src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, 1)
	visible_message("<span class='boldannounce'>The tendril falls inward, the ground around it widening into a yawning chasm!</span>")
	for(var/turf/T in range(2,src))
		if(!T.density)
			T.ChangeTurf(/turf/simulated/floor/plating/asteroid/lavaland/chasm)
	qdel(src)