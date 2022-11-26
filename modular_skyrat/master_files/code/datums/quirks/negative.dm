// Override of Signer quirk with an adjusted value appropriate for Skyrat balance.
// The stock TG quirk is valued at 4 points.
/datum/quirk/item_quirk/signer
	value = 2

// Override of Pushover quirk which changes the icon.
/datum/quirk/pushover
	icon = "people-pulling"

/datum/quirk/equipping/nerve_staple
	name = "Nerve Stapled"
	desc = "You're a pacifist. Not because you want to be, but because of the device stapled into your eye."
	value = -10 // pacifism = -8, losing eye slots = -2
	gain_text = span_danger("You suddenly can't raise a hand to hurt others!")
	lose_text = span_notice("You think you can defend yourself again.")
	medical_record_text = "Patient is nerve stapled and is unable to harm others."
	icon = "hand-peace"
	forced_items = list(/obj/item/clothing/glasses/nerve_staple = list(ITEM_SLOT_EYES))
	/// The nerve staple attached to the quirk
	var/obj/item/clothing/glasses/nerve_staple/staple

/datum/quirk/equipping/nerve_staple/on_equip_item(obj/item/equipped, successful)
	if (!istype(equipped, /obj/item/clothing/glasses/nerve_staple))
		return
	staple = equipped

/datum/quirk/equipping/nerve_staple/remove()
	. = ..()
	if (!staple || staple != quirk_holder.get_item_by_slot(ITEM_SLOT_EYES))
		return
	to_chat(quirk_holder, span_warning("The nerve staple suddenly falls off your face and melts[istype(quirk_holder.loc, /turf/open/floor) ? " on the floor" : ""]!"))
	qdel(staple)

// Re-labels TG brainproblems to be more generic. There never was a tumor anyways!
/datum/quirk/item_quirk/brainproblems
	name = "Brain Degeneration"
	desc = "You have a lethal condition in your brain that is slowly destroying it. Better bring some mannitol!"
	medical_record_text = "Patient has a lethal condition in their brain that is slowly causing brain death."

// Override of Brain Tumor quirk for robotic/synthetic species with posibrains.
// Does not appear in TGUI or the character preferences window.
/datum/quirk/item_quirk/brainproblems/synth
	name = "Positronic Cascade Anomaly"
	desc = "Your positronic brain is slowly corrupting itself due to a cascading anomaly. Better bring some liquid solder!"
	gain_text = "<span class='danger'>You feel glitchy.</span>"
	lose_text = "<span class='notice'>You no longer feel glitchy.</span>"
	medical_record_text = "Patient has a cascading anomaly in their brain that is slowly causing brain death."
	icon = "bp_synth_brain"
	mail_goodies = list(/obj/item/storage/pill_bottle/liquid_solder/braintumor)
	hidden_quirk = TRUE

// If brainproblems is added to a synth, this detours to the brainproblems/synth quirk.
// TODO: Add more brain-specific detours when PR #16105 is merged
/datum/quirk/item_quirk/brainproblems/add_to_holder(mob/living/new_holder, quirk_transfer)
	if(!(isrobotic(new_holder) && (src.type == /datum/quirk/item_quirk/brainproblems)))
		// Defer to TG brainproblems if the character isn't robotic.
		return ..()
	// TODO: Check brain type and detour to appropriate brainproblems quirk
	var/datum/quirk/item_quirk/brainproblems/synth/bp_synth = new
	qdel(src)
	return bp_synth.add_to_holder(new_holder, quirk_transfer)

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

// Override of Blood Deficiency quirk for robotic/synthetic species.
// Does not appear in TGUI or the character preferences window.
/datum/quirk/blooddeficiency/synth
	name = "Hydraulic Leak"
	desc = "Your body's hydraulic fluids are leaking through their seals."
	medical_record_text = "Patient requires regular treatment for hydraulic fluid loss."
	icon = "bd_synth_tint"
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

// Override which allows Skyrat's unique races to interoperate with the quirk.
// If blooddeficiency is added to a robotic or jelly person, this detours to the quirk to an optimized subclass.
/datum/quirk/blooddeficiency/add_to_holder(mob/living/new_holder, quirk_transfer)
	// No-op if adding a subclass.
	if (src.type != /datum/quirk/blooddeficiency)
		return

	// Add optimized subclasses depending on species.
	if((isrobotic(new_holder)))
		var/datum/quirk/blooddeficiency/synth/bd_synth = new
		qdel(src)
		return bd_synth.add_to_holder(new_holder, quirk_transfer)

	if ((isjellyperson(new_holder)))
		var/datum/quirk/blooddeficiency/jelly/bd_jelly = new
		qdel(src)
		return bd_jelly.add_to_holder(new_holder, quirk_transfer)

	// Use default behavior if the character isn't robotic or jelly.
	return ..()

/datum/quirk/bad_hearing
	name = "Bad Hearing"
	desc = "Your hearing is impaired. Far-away sounds are muffled, and you can't hear whispers."
	icon = "ear-listen"
	value = -2
	gain_text = "<span class='danger'>Everything sounds muffled.</span>"
	lose_text = "<span class='notice'>You can hear everything clearly!</span>"
	medical_record_text = "Patient has moderate hearing loss."
	hardcore_value = 1

/datum/quirk/bad_hearing/add()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_HEAR, PROC_REF(hear_badly))

/datum/quirk/bad_hearing/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_HEAR)

/// Signal handler for [COMSIG_MOVABLE_HEAR]
/// This signal handler cancels and stars out messages for Bad Hearing.
/datum/quirk/bad_hearing/proc/hear_badly(mob/living/source, list/message_args)
	SIGNAL_HANDLER

	var/mob/living/speaker = message_args[HEARING_SPEAKER]
	// Do nothing to the message if we're the speaker or "hearing" sign language.
	if((speaker == quirk_holder) || HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	var/distance = get_dist(src, get_turf(speaker))
	if(message_args[HEARING_MESSAGE_MODE][WHISPER_MODE] == MODE_WHISPER)
		if(distance <= 1)
			return
		// Can't hear whispering unless it's from an adjacent turf.
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_EMOTE] = "[speaker.verb_whisper] something but you cannot hear [speaker.p_them()]."
	else if(distance > 1)
		// Can't hear speech clearly unless it's from an adjacent turf.
		message_args[HEARING_RAW_MESSAGE] = stars(message_args[HEARING_RAW_MESSAGE], 25)
		message_args[HEARING_MESSAGE] = message_args[HEARING_RAW_MESSAGE]
