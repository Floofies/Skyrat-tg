// SKYRAT-TG OVERRIDING GOOD QUIRKS

// Override of Freerunning quirk which updates the icon.
/datum/quirk/freerunning
	icon = "person-through-window"

// Override of Light Step quirk which updates the icon.
/datum/quirk/light_step
	icon = "person-arrow-down-to-line"

// Override of Signer quirk with an adjusted value appropriate for Skyrat balance.
// The stock TG quirk is valued at 4 points.
/datum/quirk/item_quirk/signer
	value = 2
