//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

/obj/structure/fans/tiny/invisible //For blocking air in ruin doorways
	invisibility = INVISIBILITY_ABSTRACT

//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherry/bomb = 10,
				/obj/item/seeds/berry/glow = 10,
				/obj/item/seeds/sunflower/moonflower = 8
				)

///Syndicate Listening Post

/obj/effect/mob_spawn/human/lavaland_syndicate
	name = "Syndicate Bioweapon Scientist"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper_s"
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Continue your research as best you can, and try to keep a low profile. The base is rigged with explosives, <font size=6>DO NOT</font> abandon it or let it fall into enemy hands!</b>"
	outfit = /datum/outfit/lavaland_syndicate
	assignedrole = "Lavaland Syndicate"

/datum/outfit/lavaland_syndicate
	name = "Lavaland Syndicate Agent"
	r_hand = /obj/item/gun/projectile/automatic/sniper_rifle
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset/syndicate/alt
	back = /obj/item/storage/backpack
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/lavaland_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_SYNDICATE

/obj/effect/mob_spawn/human/lavaland_syndicate/comms
	name = "Syndicate Comms Agent"
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> employed in a top secret research facility developing biological weapons. Unfortunately, your hated enemy, Nanotrasen, has begun mining in this sector. <b>Monitor enemy activity as best you can, and try to keep a low profile. <font size=6>DO NOT</font> abandon the base.</b> Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!</b>"
	outfit = /datum/outfit/lavaland_syndicate/comms

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space
	flavour_text = "<span class='big bold'>You are a syndicate agent,</span><b> assigned to a small listening post station situated near your hated enemy's top secret research facility: Space Station 13. <b>Monitor enemy activity as best you can, and try to keep a low profile. <font size=6>DO NOT</font> abandon the base.</b> Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!</b>" 

/obj/effect/mob_spawn/human/lavaland_syndicate/comms/space/Initialize()
	. = ..()
	if(prob(90)) //only has a 10% chance of existing, otherwise it'll just be a NPC syndie.
		new /mob/living/simple_animal/hostile/syndicate/ranged(get_turf(src))
		return INITIALIZE_HINT_QDEL

/datum/outfit/lavaland_syndicate/comms
	name = "Lavaland Syndicate Comms Agent"
	r_hand = /obj/item/melee/energy/sword/saber
	mask = /obj/item/clothing/mask/chameleon/gps
	suit = /obj/item/clothing/suit/armor/vest

/obj/item/clothing/mask/chameleon/gps/Initialize()
	. = ..()
	new /obj/item/gps/internal/lavaland_syndicate_base(src)

/obj/item/gps/internal/lavaland_syndicate_base
	gpstag = "Encrypted Signal"
