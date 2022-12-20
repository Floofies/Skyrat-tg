// Duplicate flavortext DRYly
#define HEMO_DESC(detail) "Expensive and ultra-lightweight designer sunglasses, with [detail]blood-red lenses. Tiny engravings indicate high-quality UV-protection and bactericidal coating."
#define HEMO_ENGRAVING "<br><br>It has <b><i>[span_red("HEMO+")]</b> by <b>[span_cyan("Interdyne")]</i></b> filigree-engraved onto either side."

// Dependency of [/datum/supply_pack/goody/sunglasses_red]
/obj/item/clothing/glasses/sunglasses/interdyne
	name = "HEMO+ designer sunglasses"
	icon_state = "sunhudsec"
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/sunglasses/interdyne/Initialize(mapload)
	. = ..()
	desc = HEMO_DESC("") + HEMO_ENGRAVING

// Security HUD
/obj/item/clothing/glasses/hud/security/sunglasses/interdyne
	name = "HEMO+ security HUDSunglasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	worn_icon = 'icons/mob/clothing/eyes.dmi'
	icon_state = "sunhudsec"
	current_skin = "sunhudsec"
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/hud/security/sunglasses/interdyne/Initialize(mapload)
	. = ..()
	desc = HEMO_DESC("a security HUD and ") + HEMO_ENGRAVING

// Medical HUD
/obj/item/clothing/glasses/hud/health/sunglasses/interdyne
	name = "HEMO+ medical HUDSunglasses"
	icon_state = "sunhudsec"
	current_skin = "sunhudsec"
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/hud/health/sunglasses/interdyne/Initialize(mapload)
	. = ..()
	desc = HEMO_DESC("a medical HUD and ") + HEMO_ENGRAVING

// Diagnostic HUD
/obj/item/clothing/glasses/hud/diagnostic/sunglasses/interdyne
	name = "HEMO+ diagnostic HUDSunglasses"
	icon_state = "sunhudsec"
	current_skin = "sunhudsec"
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/hud/diagnostic/sunglasses/interdyne/Initialize(mapload)
	. = ..()
	desc = HEMO_DESC("a diagnostic HUD and ") + HEMO_ENGRAVING

// Science / Chemical Scanner HUD
/obj/item/clothing/glasses/sunglasses/chemical/interdyne
	name = "HEMO+ science sunglasses"
	icon_state = "sunhudsec"
	current_skin = "sunhudsec"
	glass_colour_type = /datum/client_colour/glass_colour/darkred

/obj/item/clothing/glasses/sunglasses/chemical/interdyne/Initialize(mapload)
	. = ..()
	desc = HEMO_DESC("a Chemical Scanner HUD and ") + HEMO_ENGRAVING

#undef HEMO_DESC
#undef HEMO_ENGRAVING
