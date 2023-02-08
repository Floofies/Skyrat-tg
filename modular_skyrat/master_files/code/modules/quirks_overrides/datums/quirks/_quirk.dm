/datum/quirk
	/// Is this quirk restricted to veteran players only?
	var/veteran_only = FALSE

	/// Is this quirk hidden from TGUI / the character preferences window?
	var/hidden_quirk = FALSE

	/// Is this a quirk disabled by disabling the ERP config?
	var/erp_quirk = FALSE

	/// A list which associates Species Datums with Quirk Datums.
	/// Associations are detours to species-specific sub-Quirks which match to a Quirk holder's Species.
	/// Subtypes should come before parent types.
	/* Example:
	 * /datum/quirk/myquirk
	 *		species_quirks = list(
	 *			/datum/species/robotic = /datum/quirk/myquirk/robotic,
	 *			/datum/species/jelly = /datum/quirk/myquirk/jelly
	 *		)
	*/
	var/list/species_quirks

/**
 * Skyrat override to add the Quirk to a new quirk_holder.
 *
 * Detours/swaps to a species-specific sub-Quirk which matches new_holder's Species, via "species_quirks".
 *
 * Performs logic to make sure new_holder is a valid holder of this quirk.
 * Returns FALSEy if there was some kind of error. Returns TRUE otherwise.
 * Arguments:
 * * new_holder - The mob to add this quirk to.
 * * quirk_transfer - If this is being added to the holder as part of a quirk transfer. Quirks can use this to decide not to spawn new items or apply any other one-time effects.
 */
/datum/quirk/add_to_holder(mob/living/new_holder, quirk_transfer, client_source)
	if(!species_quirks || !ishuman(new_holder))
		// No species Quirks, or if mob isn't Human (lacks Species Datum).
		// Add Quirk as-is.
		return ..()

	for(var/species_type in species_quirks)
		// Check Quirk holder's Species against the Species Datums in the list.
		// Any subclass of the Species can exist in the list.
		if(!is_species(new_holder, species_type))
			continue

		// Species Datum successfully matched to Quirk Datum:
		var/datum/quirk/sub_quirk = species_quirks[species_type]
		sub_quirk = new sub_quirk()
		// This null prevents infinite loop/detour, because Sub-Quirks inherit species_quirks.
		// Setting null here is convenient and removes any need to do it in the subclass.
		sub_quirk.species_quirks = null

		qdel(src)
		return sub_quirk.add_to_holder(new_holder, quirk_transfer, client_source)

	// No Species Datum matched the Quirk holder's Species Datum.
	// Add Quirk as-is without detouring.
	return ..()

/// Ensures the given items are ALWAYS equipped, no matter what the circumstances are.
/datum/quirk/equipping
	abstract_parent_type = /datum/quirk/equipping
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	/// the items that will be equipped, formatted in the way of [item_path = list of slots it can be equipped to], will not equip over nodrop items
	var/list/items = list()
	/// the items that will be forcefully equipped, formatted in the way of [item_path = list of slots it can be equipped to], will equip over nodrop items
	var/list/forced_items = list()

/datum/quirk/equipping/add_unique(client/client_source)
	var/mob/living/carbon/carbon_holder = quirk_holder
	if (!items || !carbon_holder)
		return
	var/list/equipped_items = list()
	var/list/all_items = forced_items|items
	for (var/obj/item/item_path as anything in all_items)
		if (!ispath(item_path))
			continue
		var/item = new item_path(carbon_holder.loc)
		var/success = FALSE
		// Checking for nodrop and seeing if there's an empty slot
		for (var/slot as anything in all_items[item_path])
			success = force_equip_item(carbon_holder, item, slot, check_item = FALSE)
			if (success)
				break
		// Checking for nodrop
		for (var/slot as anything in all_items[item_path])
			success = force_equip_item(carbon_holder, item, slot)
			if (success)
				break

		if ((item_path in forced_items) && !success)
			// Checking for nodrop failed, shove it into the first available slot, even if it has nodrop
			for (var/slot as anything in all_items[item_path])
				success = force_equip_item(carbon_holder, item, slot, FALSE)
				if (success)
					break
		equipped_items[item] = success
	for (var/item as anything in equipped_items)
		on_equip_item(item, equipped_items[item])

/datum/quirk/equipping/proc/force_equip_item(mob/living/carbon/target, obj/item/item, slot, check_nodrop = TRUE, check_item = TRUE)
	var/obj/item/item_in_slot = target.get_item_by_slot(slot)
	if (check_item && item_in_slot)
		if (check_nodrop && HAS_TRAIT(item_in_slot, TRAIT_NODROP))
			return FALSE
		target.dropItemToGround(item_in_slot, force = TRUE)
	return target.equip_to_slot_if_possible(item, slot, disable_warning = TRUE) // this should never not work tbh

/datum/quirk/equipping/proc/on_equip_item(obj/item/equipped, success)
	return

/// Enables you to add more breathing quirks, so you can breathe in different gases.
/datum/quirk/equipping/lungs
	abstract_parent_type = /datum/quirk/equipping/lungs
	var/obj/item/organ/internal/lungs/lungs_holding
	var/obj/item/organ/internal/lungs/lungs_added
	var/lungs_typepath = /obj/item/organ/internal/lungs
	items = list(/obj/item/clothing/accessory/breathing = list(ITEM_SLOT_BACKPACK))
	var/breath_type = "oxygen"

/datum/quirk/equipping/lungs/add(client/client_source)
	var/mob/living/carbon/human/carbon_holder = quirk_holder
	if (!istype(carbon_holder) || !lungs_typepath)
		return
	var/current_lungs = carbon_holder.getorganslot(ORGAN_SLOT_LUNGS)
	if (istype(current_lungs, lungs_typepath))
		return
	lungs_holding = current_lungs
	lungs_holding.organ_flags |= ORGAN_FROZEN
	lungs_added = new lungs_typepath
	lungs_added.Insert(carbon_holder)
	lungs_holding.moveToNullspace()

/datum/quirk/equipping/lungs/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if (!istype(carbon_holder) || !lungs_holding)
		return
	var/obj/item/organ/internal/lungs/lungs = carbon_holder.getorganslot(ORGAN_SLOT_LUNGS)
	if (lungs != lungs_added && lungs != lungs_holding)
		qdel(lungs_holding)
		return
	lungs_holding.Insert(carbon_holder, drop_if_replaced = FALSE)
	lungs_holding.organ_flags &= ~ORGAN_FROZEN

/datum/quirk/equipping/lungs/on_equip_item(obj/item/equipped, success)
	var/mob/living/carbon/human/human_holder = quirk_holder
	if (!istype(equipped, /obj/item/clothing/accessory/breathing))
		return
	var/obj/item/clothing/accessory/breathing/acc = equipped
	acc.breath_type = breath_type
	if (acc.can_attach_accessory(human_holder?.w_uniform))
		acc.attach(human_holder.w_uniform, human_holder)
