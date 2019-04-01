var/jumpdistance = 0
var/jumpspeed = 0
var/recharging_rate = 0
var/recharging_time = 0

/obj/item/storage/shoes/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "explorer"
	body_parts_covered = FEET
	slot_flags = SLOT_FEET
	resistance_flags = FIRE_PROOF
	storage_slots = 2
	can_hold = list(
		/obj/item/kitchen/knife,
		/obj/item/pen,
		/obj/item/scalpel,
		/obj/item/reagent_containers/syringe,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/implanter,
		/obj/item/screwdriver,
		/obj/item/weldingtool/mini)

/obj/item/storage/shoes/mining/jump
	name = "jump boots"
	desc = "A specialized pair of combat boots with a built-in propulsion system for rapid foward movement."
	icon_state = "jetboots"
	item_state = "jetboots"
	item_color = "hosred"
	actions_types = list(/datum/action/item_action/bhop)
	permeability_coefficient = 0.05
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/recharging_rate = 60 //default 6 seconds between each dash
	var/recharging_time = 0 //time until next dash