/// Breathing Dogtag for the Nitrogen Breather Quirk
/obj/item/clothing/accessory/breathing
	name = "breathing dogtag"
	desc = "Dogtag that lists what you breathe."
	icon_state = "allergy"
	above_suit = FALSE
	minimize_when_attached = TRUE
	attachment_slot = CHEST
	var/breath_type

/obj/item/clothing/accessory/breathing/examine(mob/user)
	. = ..()
	. += "The dogtag reads: I breathe [breath_type]."

/obj/item/clothing/accessory/breathing/on_uniform_equip(obj/item/clothing/under/uniform, user)
	. = ..()
	RegisterSignal(uniform, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/obj/item/clothing/accessory/breathing/on_uniform_dropped(obj/item/clothing/under/uniform, user)
	. = ..()
	UnregisterSignal(uniform, COMSIG_PARENT_EXAMINE)

/obj/item/clothing/accessory/breathing/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "The dogtag reads: I breathe [breath_type]."
