/**
 * This proc is used to insert an item into an existing pile, or create a new pile.
 * Not called except when added to an item's [/obj/item/proc/attackby] via override.
 *
 * Items in the pile are rendered in random positions, and with random rotations.
 *
 * Arguments:
 * * item - Either another item or a pile that this item gets inserted into.
 * * user - The Mob attempting to add-to/make the pile.
 */
/obj/item/proc/add_to_pile(obj/item/item, mob/living/user)
	// Add this item to an existing pile.
	if(istype(item, /obj/item/pile))
		var/obj/item/pile/existing_pile = item
		if(!existing_pile.add_items(user, src))
			to_chat(user, span_warning("You can't pick up any more of the [name]!"))
			return FALSE
		return TRUE
	// Create a new pile and add this item to it.
	if(istype(item, /obj/item) && (item.w_class > PILE_MAX_WEIGHT_CLASS))
		if(item.w_class > PILE_MAX_WEIGHT_CLASS)
			to_chat(user, span_warning("You can't pick up any more of the [name]!"))
			return FALSE
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		var/obj/item/pile/new_pile = new (drop_location())
		new_pile.add_items(user, src, update = FALSE)
		new_pile.add_items(user, item)
		new_pile.pickup(user)
		user.put_in_active_hand(new_pile)
		return TRUE

// Overrides which allow various items to be stacked in piles.

// Ammo Casing
/obj/item/ammo_casing/attackby(obj/item/item, mob/living/user, params)
	if(!add_to_pile(item, user))
		return ..()

// Pen
/obj/item/pen/attackby(obj/item/item, mob/living/user, params)
	if(!add_to_pile(item, user))
		return ..()

// Glass Shard
/obj/item/shard/attackby(obj/item/item, mob/living/user, params)
	if(!add_to_pile(item, user))
		return ..()

// Throwing Star
/obj/item/throwing_star/attackby(obj/item/item, mob/living/user, params)
	if(!add_to_pile(item, user))
		return ..()

// Cigarette
/obj/item/clothing/mask/cigarette/attackby(obj/item/item, mob/living/user, params)
	// Allow lighters to light the cig up.
	if(item.get_temperature() || !add_to_pile(item, user))
		return ..()

// Cigarette Butt
/obj/item/cigbutt/attackby(obj/item/item, mob/living/user, params)
	if(!add_to_pile(item, user))
		return ..()

// Paper
/obj/item/paper/attackby(obj/item/item, mob/living/user, params)
	// Allow pens to write, and lighters to light the paper on fire.
	if(istype(item, /obj/item/pen) || item.get_temperature() || !add_to_pile(item, user))
		return ..()
