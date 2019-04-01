// This is just a copypaste of mine_turfs.dm, but modified
/**********************Mineral deposits**************************/

#define NORTH_EDGING	"north"
#define SOUTH_EDGING	"south"
#define EAST_EDGING		"east"
#define WEST_EDGING		"west"

var/global/list/lavaland_rockTurfEdgeCache = list( 
	NORTH_EDGING = image('icons/turf/mining.dmi', "rock_side_lavaland_n", layer = 2.5),
	SOUTH_EDGING = image('icons/turf/mining.dmi', "rock_side_lavaland_s", layer = 2.5),
	EAST_EDGING = image('icons/turf/mining.dmi', "rock_side_lavaland_e", layer = 2.5),
	WEST_EDGING = image('icons/turf/mining.dmi', "rock_side_lavaland_w", layer = 2.5))

/turf/simulated/mineral/lavaland //wall piece
	name = "Rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_nochance_lavaland"
	oxygen = 14
	nitrogen = 23
	temperature = 300
	layer = 3 // Above the overlays

/turf/simulated/mineral/lavaland/New()
	GLOB.lavaland_mineral_turfs += src
	if(mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/simulated/mineral/lavaland/random))
					Spread(T)

	HideRock()

/turf/simulated/mineral/lavaland/HideRock()
	if(hidden)
		name = "rock"
		icon_state = "rock_lavaland"
	return

/turf/simulated/mineral/lavaland/add_edges()
	var/turf/T
	if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)))
		T = get_step(src, NORTH)
		if(T)
			T.overlays += lavaland_rockTurfEdgeCache[SOUTH_EDGING]
	if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)))
		T = get_step(src, SOUTH)
		if(T)
			T.overlays += lavaland_rockTurfEdgeCache[NORTH_EDGING]
	if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)))
		T = get_step(src, EAST)
		if(T)
			T.overlays += lavaland_rockTurfEdgeCache[WEST_EDGING]
	if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)))
		T = get_step(src, WEST)
		if(T)
			T.overlays += lavaland_rockTurfEdgeCache[EAST_EDGING]

/turf/simulated/mineral/lavaland/random
	name = "mineral deposit"
	icon_state = "rock_lavaland"
	var/mineralSpawnChanceList = list(
		"Uranium" = 5, "Diamond" = 1, "Gold" = 10,
		"Silver" = 12, "Plasma" = 20, "Iron" = 40,
		"Gibtonite" = 4, "Cave" = 2, "BScrystal" = 1,
		"Titanium" = 11)
	var/mineralChance = 13

/turf/simulated/mineral/lavaland/random/New()
	..()
	if(prob(mineralChance))
		var/mName = pickweight(mineralSpawnChanceList) //temp mineral name

		if(mName)
			var/turf/simulated/mineral/lavaland/M
			switch(mName)
				if("Uranium")
					M = new/turf/simulated/mineral/lavaland/uranium(src)
				if("Iron")
					M = new/turf/simulated/mineral/lavaland/iron(src)
				if("Diamond")
					M = new/turf/simulated/mineral/lavaland/diamond(src)
				if("Gold")
					M = new/turf/simulated/mineral/lavaland/gold(src)
				if("Silver")
					M = new/turf/simulated/mineral/lavaland/silver(src)
				if("Plasma")
					M = new/turf/simulated/mineral/lavaland/plasma(src)
				if("Cave")
					new/turf/simulated/floor/plating/asteroid/lavaland/basalt/cave(src)
				if("Gibtonite")
					M = new/turf/simulated/mineral/lavaland/gibtonite(src)
				if("Bananium")
					M = new/turf/simulated/mineral/lavaland/clown(src)
				if("Tranquillite")
					M = new/turf/simulated/mineral/lavaland/mime(src)
				if("Titanium")
					M = new/turf/simulated/mineral/lavaland/titanium(src)
				if("BScrystal")
					M = new/turf/simulated/mineral/lavaland/bscrystal(src)
			if(M)
				M.mineralAmt = rand(1, 5)
				src = M
				M.levelupdate()
	return


/turf/simulated/mineral/lavaland/random/high_chance
	icon_state = "rock_highchance_lavaland"
	mineralChance = 25
	mineralSpawnChanceList = list(
		"Uranium" = 35, "Diamond" = 30, "Gold" = 45,
		"Silver" = 50, "Plasma" = 50, "BScrystal" = 20,
		"Titanium" = 45)


/turf/simulated/mineral/lavaland/random/high_chance_clown
	mineralChance = 40
	mineralSpawnChanceList = list(
		"Uranium" = 35, "Diamond" = 2,
		"Gold" = 5, "Silver" = 5, "Plasma" = 25,
		"Iron" = 30, "Bananium" = 15, "Tranquillite" = 15, "BScrystal" = 10)

/turf/simulated/mineral/lavaland/random/high_chance/New()
	icon_state = "rock_lavaland"
	..()

/turf/simulated/mineral/lavaland/random/low_chance
	icon_state = "rock_lowchance_lavaland"
	mineralChance = 6
	mineralSpawnChanceList = list(
		"Uranium" = 2, "Diamond" = 1, "Gold" = 4,
		"Silver" = 6, "Plasma" = 15, "Iron" = 40,
		"Gibtonite" = 2, "BScrystal" = 1, "Titanium" = 4)

/turf/simulated/mineral/lavaland/random/low_chance/New()
	icon_state = "rock_lavaland"
	..()

/turf/simulated/mineral/lavaland/random/labormineral
	icon_state = "rock_labor_lavaland"
	mineralSpawnChanceList = list("Uranium" = 1, "Iron" = 100, "Diamond" = 1, "Gold" = 1, "Silver" = 1, "Plasma" = 1) // Dear god they hate these people

/turf/simulated/mineral/lavaland/random/labormineral/New()
	icon_state = "rock_lavaland"
	..()


/turf/simulated/mineral/lavaland/iron
	name = "iron deposit"
	icon_state = "rock_Iron_lavaland"
	mineralType = /obj/item/stack/ore/iron
	mineralName = "Iron"
	spreadChance = 20
	spread = 1
	hidden = 0

/turf/simulated/mineral/lavaland/uranium
	name = "uranium deposit"
	mineralType = /obj/item/stack/ore/uranium
	mineralName = "Uranium"
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Uranium"

/turf/simulated/mineral/lavaland/diamond
	name = "diamond deposit"
	mineralType = /obj/item/stack/ore/diamond
	mineralName = "Diamond"
	spreadChance = 0
	spread = 1
	hidden = 1
	scan_state = "rock_Diamond"

/turf/simulated/mineral/lavaland/gold
	name = "gold deposit"
	mineralType = /obj/item/stack/ore/gold
	mineralName = "Gold"
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Gold"

/turf/simulated/mineral/lavaland/silver
	name = "silver deposit"
	mineralType = /obj/item/stack/ore/silver
	mineralName = "Silver"
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Silver"

/turf/simulated/mineral/lavaland/titanium
	name = "titanium deposit"
	mineralType = /obj/item/stack/ore/titanium
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Titanium"

/turf/simulated/mineral/lavaland/plasma
	name = "plasma deposit"
	icon_state = "rock_Plasma"
	mineralType = /obj/item/stack/ore/plasma
	mineralName = "Plasma"
	spreadChance = 8
	spread = 1
	hidden = 1
	scan_state = "rock_Plasma"

/turf/simulated/mineral/lavaland/clown
	name = "bananium deposit"
	icon_state = "rock_Clown"
	mineralType = /obj/item/stack/ore/bananium
	mineralName = "Bananium"
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	hidden = 0

/turf/simulated/mineral/lavaland/mime
	name = "tranquillite deposit"
	icon_state = "rock_Mime"
	mineralType = /obj/item/stack/ore/tranquillite
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	hidden = 0

/turf/simulated/mineral/lavaland/bscrystal
	name = "bluespace crystal deposit"
	icon_state = "rock_BScrystal"
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralName = "Bluespace crystal"
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	hidden = 1
	scan_state = "rock_BScrystal"

/turf/simulated/mineral/lavaland/gibtonite
	name = "gibtonite deposit"
	icon_state = "rock_Gibtonite_lavaland"
	mineralAmt = 1
	mineralName = "Gibtonite"
	spreadChance = 0
	spread = 0
	hidden = 1
	scan_state = "rock_Gibtonite_lavaland"

// This is needed because otherwise the rocks leave behind regular, airless asteroid
/turf/simulated/mineral/lavaland/gets_drilled()
	if(mineralType && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for(i=0;i<mineralAmt;i++)
			new mineralType(src)
		feedback_add_details("ore_mined","[mineralType]|[mineralAmt]")
	ChangeTurf(/turf/simulated/floor/plating/asteroid/lavaland/basalt)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction
	// This is bullshit and I know it, but it ONLY works this way
	// I will gladly fight anyone who opposes me -AA07
	for(var/turf/M in range(1,src))
		// Only for lavaland turfs, it breaks other turfs
		if(istype(M, /turf/simulated/floor/plating/asteroid/lavaland/basalt) || istype(M, /turf/simulated/mineral))
			M.updateLavaMineralOverlays()
	if(rand(1,750) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		new /obj/structure/closet/crate/secure/loot(src)

	return

// So much bullshit to be able to switch between asteroid and lavaland
/turf/proc/updateLavaMineralOverlays()
	src.overlays.Cut()
	if(istype(get_step(src, NORTH), /turf/simulated/mineral/lavaland))
		src.overlays += lavaland_rockTurfEdgeCache[NORTH_EDGING]
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral/lavaland))
		src.overlays += lavaland_rockTurfEdgeCache[SOUTH_EDGING]
	if(istype(get_step(src, EAST), /turf/simulated/mineral/lavaland))
		src.overlays += lavaland_rockTurfEdgeCache[EAST_EDGING]
	if(istype(get_step(src, WEST), /turf/simulated/mineral/lavaland))
		src.overlays += lavaland_rockTurfEdgeCache[WEST_EDGING]


/turf/proc/fullUpdateLavaMineralOverlays()
	for(var/turf/M in range(1,src))
		M.updateLavaMineralOverlays()

// CAVES
/turf/simulated/floor/plating/asteroid/lavaland/basalt/cave
	var/length = 100
	var/mob_spawn_list = list("Goldgrub" = 5, "Goliath" = 25, "Basilisk" = 20, "Hivelord" = 15, "Dragon" = 2, "Bubblegum" = 1, "Colossus" = 1, "T_Watcher" = 2, "T_Goliath" = 2, "T_Legion" = 2)
	var/sanity = 1

/turf/simulated/floor/plating/asteroid/lavaland/basalt/cave/New(loc, var/length, var/go_backwards = 1, var/exclude_dir = -1)
	if(!istype(src.loc, /area/lavaland/surface/outdoors/unexplored/danger)) // No caves in the starting area
		ChangeTurf(/turf/simulated/mineral/lavaland)
		return
	// If length (arg2) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!length)
		src.length = rand(25, 50)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)
	..()

/turf/simulated/floor/plating/asteroid/lavaland/basalt/cave/proc/make_tunnel(var/dir)
	var/turf/simulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/simulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				new src.type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)

/turf/simulated/floor/plating/asteroid/lavaland/basalt/cave/proc/SpawnFloor(var/turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/space) || !istype(S.loc, /area/lavaland/surface/outdoors/unexplored/danger))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)
	var/turf/simulated/floor/t = new /turf/simulated/floor/plating/asteroid/lavaland/basalt(T)
	spawn(2)
		t.fullUpdateLavaMineralOverlays()

/turf/simulated/floor/plating/asteroid/lavaland/basalt/cave/proc/SpawnMonster(var/turf/T)
	if(prob(30))
		if(!istype(loc, /area/lavaland/surface/outdoors/unexplored/danger))
			return
		for(var/atom/A in range(15,T))//Lowers chance of mob clumps
			if(istype(A, /mob/living/simple_animal/hostile))
				return
		var/randumb = pickweight(mob_spawn_list)
		switch(randumb)
			if("Goliath")
				new /mob/living/simple_animal/hostile/asteroid/goliath/beast(T)
			if("Goldgrub")
				new /mob/living/simple_animal/hostile/asteroid/goldgrub(T)
			if("Basilisk")
				new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher(T)
			if("Hivelord")
				new /mob/living/simple_animal/hostile/asteroid/hivelord/legion(T)
			if("Bubblegum")
				if(bubblegum_spawned == 0) // Only 1 bubblegum may spawn
					bubblegum_spawned = 1
					new /mob/living/simple_animal/hostile/megafauna/bubblegum(T)
			if("Colossus")
				new /mob/living/simple_animal/hostile/megafauna/colossus(T)
			if("Dragon")
				new /mob/living/simple_animal/hostile/megafauna/dragon(T)
			if("T_Watcher")
				new /mob/living/simple_animal/hostile/spawner/lavaland(T)
			if("T_Goliath")
				new /mob/living/simple_animal/hostile/spawner/lavaland/goliath(T)
			if("T_Legion")
				new /mob/living/simple_animal/hostile/spawner/lavaland/legion(T)
	return

#undef NORTH_EDGING
#undef SOUTH_EDGING
#undef EAST_EDGING
#undef WEST_EDGING
