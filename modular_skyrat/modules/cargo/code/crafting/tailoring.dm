// Security HUD
/datum/crafting_recipe/hudsunsec/interdyne
	name = "HEMO+ Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses/interdyne = 1,
				/obj/item/stack/cable_coil = 5)

/datum/crafting_recipe/hudsunsecremoval/interdyne
	name = "HEMO+ Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses/interdyne = 1)

// Medical HUD
/datum/crafting_recipe/hudsunmed/interdyne
	name = "HEMO+ Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses/interdyne = 1,
				/obj/item/stack/cable_coil = 5)

/datum/crafting_recipe/hudsunmedremoval/interdyne
	name = "HEMO+ Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses/interdyne = 1)

// Diagnostic HUD
/datum/crafting_recipe/hudsundiag/interdyne
	name = "HEMO+ Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
			  	/obj/item/clothing/glasses/sunglasses/interdyne = 1,
			 	/obj/item/stack/cable_coil = 5)

/datum/crafting_recipe/hudsundiagremoval/interdyne
	name = "HEMO+ Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses/interdyne = 1)

// Science & Chemical Scanner HUD
/datum/crafting_recipe/scienceglasses/interdyne
	name = "HEMO+ Science Glasses"
	result = /obj/item/clothing/glasses/sunglasses/chemical/interdyne
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses/interdyne = 1,
				/obj/item/stack/cable_coil = 5)

/datum/crafting_recipe/scienceglassesremoval/interdyne
	name = "HEMO+ Chemical Scanner removal"
	result = /obj/item/clothing/glasses/sunglasses/interdyne
	reqs = list(/obj/item/clothing/glasses/sunglasses/chemical/interdyne = 1)
