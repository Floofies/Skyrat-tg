/datum/quirk
	/// Is this quirk restricted to veteran players only?
	var/veteran_only = FALSE

	/// Is this quirk hidden from TGUI / the character preferences window?
	var/hidden_quirk = FALSE

	/// Is this a quirk disabled by disabling the ERP config?
	var/erp_quirk = FALSE

	/// A list which associates Species typepaths with Quirk typepaths.
	/// Any associations here will detour the parent Quirk to the specified sub-Quirk.
	/* Example:
	 * /datum/quirk/blooddeficiency
	 *		species_quirks = list(
	 *			/datum/species/robotic = /datum/quirk/blooddeficiency/synth,
	 *			/datum/species/jelly = /datum/quirk/blooddeficiency/jelly
	 *		)
	*/
	var/list/species_quirks

// Override which allows Skyrat's unique races to interoperate with certain Quirks
/datum/quirk/add_to_holder(mob/living/new_holder, quirk_transfer)
	if(!species_quirks)
		return ..()

	if(!ishuman(new_holder))
		return ..()

	var/mob/living/carbon/human/human_holder = new_holder
	var/matched_quirk = species_quirks[human_holder.dna.species.type]
	if (!matched_quirk)
		return ..()

	var/datum/quirk/species_quirk = new matched_quirk
	// Quirks may subclass, so setting this to null prevents infinite detouring.
	species_quirk.species_quirks = null
	species_quirk.add_to_holder(new_holder, quirk_transfer)
	qdel(src)
