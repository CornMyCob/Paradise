//temporary visual effects
/obj/effect/temp_visual
	anchored = 1
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/duration = 10
	var/randomdir = TRUE
	var/timerid

/obj/effect/temp_visual/New()
	if(randomdir)
		setDir(pick(cardinal))

	timerid = QDEL_IN(src, duration)

/obj/effect/temp_visual/singularity_act()
	return

/obj/effect/temp_visual/singularity_pull()
	return

/obj/effect/temp_visual/ex_act()
	return

/obj/effect/temp_visual/dir_setting
	randomdir = FALSE

/obj/effect/temp_visual/dir_setting/New(loc, set_dir)
	if(set_dir)
		setDir(set_dir)
	..()

/obj/effect/temp_visual/Destroy()
	. = ..()
	deltimer(timerid)

// Firing
/obj/effect/temp_visual/dir_setting/firing_effect
	icon = 'icons/effects/effects.dmi'
	icon_state = "firing_effect"
	duration = 2

/obj/effect/temp_visual/dir_setting/firing_effect/setDir(newdir)
	switch(newdir)
		if(NORTH)
			layer = BELOW_MOB_LAYER
			pixel_x = rand(-3,3)
			pixel_y = rand(4,6)
		if(SOUTH)
			pixel_x = rand(-3,3)
			pixel_y = rand(-1,1)
		else
			pixel_x = rand(-1,1)
			pixel_y = rand(-1,1)
	..()

/obj/effect/temp_visual/dir_setting/firing_effect/energy
	icon_state = "firing_effect_energy"
	duration = 3

/obj/effect/temp_visual/dir_setting/firing_effect/magic
	icon_state = "shieldsparkles"
	duration = 3

/obj/effect/temp_visual/small_smoke
	icon_state = "smoke"
	duration = 50

/obj/effect/temp_visual/small_smoke/halfsecond
	duration = 5

// Bleed

/obj/effect/temp_visual/bleed
	name = "bleed"
	icon = 'icons/effects/bleed.dmi'
	icon_state = "bleed0"
	duration = 10
	var/shrink = TRUE

/obj/effect/temp_visual/bleed/Initialize(mapload, atom/size_calc_target)
	. = ..()
	var/size_matrix = matrix()
	if(size_calc_target)
		layer = size_calc_target.layer + 0.01
		var/icon/I = icon(size_calc_target.icon, size_calc_target.icon_state, size_calc_target.dir)
		size_matrix = matrix() * (I.Height()/world.icon_size)
		transform = size_matrix //scale the bleed overlay's size based on the target's icon size
	var/matrix/M = transform
	if(shrink)
		M = size_matrix*0.1
	else
		M = size_matrix*2
	animate(src, alpha = 20, transform = M, time = duration, flags = ANIMATION_PARALLEL)

/obj/effect/temp_visual/bleed/explode
	icon_state = "bleed10"
	duration = 12
	shrink = FALSE
