// SKYRAT-TG OVERRIDING NEGATIVE QUIRKS

// Override of Pushover quirk which changes the icon.
/datum/quirk/pushover
	icon = "people-pulling"

// Re-labels TG brainproblems to be more generic. There never was a tumor anyways!
// Includes species-specific quirks for synthetic species.
/datum/quirk/item_quirk/brainproblems
	name = "Brain Degeneration"
	desc = "You have a lethal condition in your brain that is slowly destroying it. Better bring some mannitol!"
	medical_record_text = "Patient has a lethal condition in their brain that is slowly causing brain death."
	species_quirks = list( /datum/species/robotic = /datum/quirk/item_quirk/brainproblems/synth )

// Override of Brain Tumor quirk for robotic/synthetic species with synthetic brains.
// Does not appear in TGUI or the character preferences window.
/datum/quirk/item_quirk/brainproblems/synth
	name = "Positronic Cascade Anomaly"
	desc = "Your positronic brain is slowly corrupting itself due to a cascading anomaly. Better bring some liquid solder!"
	gain_text = "<span class='danger'>You feel glitchy.</span>"
	lose_text = "<span class='notice'>You no longer feel glitchy.</span>"
	mail_goodies = list(/obj/item/storage/pill_bottle/liquid_solder/braintumor)
	hidden_quirk = TRUE

// Override that adds custom flavortext for synthetic brains.
/datum/quirk/item_quirk/brainproblems/synth/add_to_holder(mob/living/carbon/new_holder, quirk_transfer)
	var/obj/item/organ/internal/brain/synth_brain = new_holder.getorganslot(ORGAN_SLOT_BRAIN)
	if (istype(synth_brain, /obj/item/organ/internal/brain/ipc_positron/circuit))
		name = "Processor Firmware Bug"
	else if (istype(synth_brain, /obj/item/organ/internal/brain/ipc_positron/mmi))
		name = "Interface Rejection Syndrome"

	medical_record_text = "Patient has a malfunction in their [synth_brain] that is slowly causing brain death."
	..()

// Synthetics get liquid_solder with Brain Tumor instead of mannitol.
/datum/quirk/item_quirk/brainproblems/synth/add_unique()
	give_item_to_holder(
		/obj/item/storage/pill_bottle/liquid_solder/braintumor,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = "These will keep you alive until you can secure a supply of medication. Don't rely on them too much!",
	)

// Override which includes species-specific quirks for jelly and synthetic species.
/datum/quirk/blooddeficiency
	species_quirks = list (
		/datum/species/robotic = /datum/quirk/blooddeficiency/synth,
		/datum/species/jelly = /datum/quirk/blooddeficiency/jelly
	)

// Override of Blood Deficiency quirk for robotic/synthetic species.
// Does not appear in TGUI or the character preferences window.
/datum/quirk/blooddeficiency/synth
	name = "Hydraulic Leak"
	desc = "Your body's hydraulic fluids are leaking through their seals."
	medical_record_text = "Patient requires regular treatment for hydraulic fluid loss."
	mail_goodies = list(/obj/item/reagent_containers/blood/oil)
	hidden_quirk = TRUE

// Override of Blood Deficiency quirk for jelly/slime species.
// Does not appear in TGUI or the character preferences window.
/datum/quirk/blooddeficiency/jelly
	name = "Jelly Dessication"
	desc = "Your body can't produce enough jelly to sustain itself."
	medical_record_text = "Patient requires regular treatment for slime jelly loss."
	mail_goodies = list(/obj/item/reagent_containers/blood/jelly)
	hidden_quirk = TRUE

// Omits the NOBLOOD check for jelly/slime species.
/datum/quirk/blooddeficiency/jelly/process(delta_time)
	if(quirk_holder.stat == DEAD)
		return

	var/mob/living/carbon/human/carbon_target = quirk_holder
	if (carbon_target.blood_volume <= min_blood)
		return

	carbon_target.blood_volume = max(min_blood, carbon_target.blood_volume - drain_rate * delta_time)
