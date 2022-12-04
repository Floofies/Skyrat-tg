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

// Override detours/swaps to a species-specific Quirk if one exists in species_quirks.
// Allows Skyrat's unique races to interoperate with certain Quirks.
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

/datum/quirk/equipping
	abstract_parent_type = /datum/quirk/equipping
	/// the items that will be equipped, formatted in the way of [item_path = list of slots it can be equipped to], will not equip over nodrop items
	var/list/items = list()
	/// the items that will be forcefully equipped, formatted in the way of [item_path = list of slots it can be equipped to], will equip over nodrop items
	var/list/forced_items = list()

/datum/quirk/equipping/add_unique()
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

/datum/quirk/equipping/lungs
	abstract_parent_type = /datum/quirk/equipping/lungs
	var/obj/item/organ/internal/lungs/lungs_holding
	var/obj/item/organ/internal/lungs/lungs_added
	var/lungs_typepath = /obj/item/organ/internal/lungs
	items = list(/obj/item/clothing/accessory/breathing = list(ITEM_SLOT_BACKPACK))
	var/breath_type = "oxygen"

/datum/quirk/equipping/lungs/add()
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
