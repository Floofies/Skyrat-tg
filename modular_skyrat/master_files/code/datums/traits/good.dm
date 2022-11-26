// Override of Freerunning quirk which updates the icon.
/datum/quirk/freerunning
	icon = "person-through-window"

// Override of Light Step quirk which updates the icon.
/datum/quirk/light_step
	icon = "person-arrow-down-to-line"

// SKYRAT GOOD TRAITS

/datum/quirk/hard_soles
	name = "Hardened Soles"
	desc = "You're used to walking barefoot, and won't receive the negative effects of doing so."
	value = 2
	mob_trait = TRAIT_HARD_SOLES
	gain_text = span_notice("The ground doesn't feel so rough on your feet anymore.")
	lose_text = span_danger("You start feeling the ridges and imperfections on the ground.")
	medical_record_text = "Patient's feet are more resilient against traction."
	icon = "shoe-prints"

/datum/quirk/linguist
	name = "Linguist"
	desc = "You're a student of numerous languages and come with an additional language point."
	value = 4
	mob_trait = QUIRK_LINGUIST
	gain_text = span_notice("Your brain seems more equipped to handle different modes of conversation.")
	lose_text = span_danger("Your grasp of the finer points of Draconic idioms fades away.")
	medical_record_text = "Patient demonstrates a high brain plasticity in regards to language learning."
	icon = "globe"
