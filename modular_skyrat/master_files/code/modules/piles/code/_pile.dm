/**
 * Pile is a small "item stack" used to group several items of different types together.
 * Piles are created by combining two or more compatible items. Piles also render the sprites of their contents as overlays.
 *
 * Pile increases its weight class if there is more than 2 items inside it.
 *
 * You can make an item Pile-compatible by overriding/detouring [/obj/item/proc/attackby] to call [/obj/item/proc/add_to_pile].
 */
/obj/item/pile
	name = "pile of items"
	desc = "Several items collected into a pile."
	icon_state = "nothing"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	/// If set to TRUE, then all the items drop to the floor when thrown or dropped.
	var/loose_pile = TRUE
	// A list of items contained in the pile.
	var/list/obj/item/items = list()

/obj/item/pile/Destroy()
	if (!isnull(items))
		QDEL_LIST(items)
	return ..()

// List contents of the pile in examine.
/obj/item/pile/examine(mob/user)
	. = ..()
	if(length(items) == 0)
		return
	. += "<br>Items in the pile:"
	for(var/obj/item/item in items)
		. += "<br>A [item.name]."

// Pick up an item from the pile.
/obj/item/pile/attack_hand(mob/user, list/modifiers)
	if(loc != user)
		return ..()
	if(!ishuman(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = FALSE, need_hands = !iscyborg(user)))
		return
	if(user.get_inactive_held_item() != src)
		return
	var/obj/item/selected_item = remove_item(user)
	selected_item.pickup(user)
	user.put_in_hands(selected_item)

/obj/item/pile/attack_hand_secondary(mob/living/user, list/modifiers)
	attack_hand(user, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// Add an item to the pile, or transfer an item from this pile to a different pile.
/obj/item/pile/attackby(obj/item/item, mob/living/user, params)
	if(istype(item, /obj/item/pile))
		var/obj/item/pile/existing_pile = item
		if(!existing_pile.add_items(user, src))
			to_chat(user, span_warning("You can't pick up any more items!"))
			return

	if(istype(item, /obj/item))
		if(!add_items(user, item))
			to_chat(user, span_warning("You can't pick up any more of the [item.name]!"))

	return ..()

// Display a radial menu of items to the user, and allow them to pick one item for removal.
/obj/item/pile/attack_self(mob/living/user)
	if(!isliving(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		return

	var/list/radial = list()
	for(var/obj/item/item in items)
		radial[item] = image(icon = item.icon, icon_state = item.icon_state)

	var/obj/item/choice = show_radial_menu(usr, src, radial, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	var/obj/item/selected_item = remove_item(user, choice)
	selected_item.pickup(user)
	user.put_in_hands(selected_item)

// Disperse pile if it was thrown, stayed together mid-flight, and then impacted something.
/obj/item/pile/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	disperse_pile()

// Disperse pile if it was thrown, or simultaneously re-throw every item at the target.
/obj/item/pile/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	if(loose_pile)
		disperse_pile()
		return
	var/list/obj/item/thrown_items = remove_all_items()
	for(var/obj/item/item in thrown_items)
		item.forceMove(drop_location())
		item.throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force, gentle, quickstart)
	qdel(src)

// Disperse pile if dropped.
/obj/item/pile/dropped(mob/user, datum/thrownthing/throwingdatum)
	if(loose_pile && !istype(throwingdatum, /datum/thrownthing))
		if(loc != user)
			disperse_pile()
	return ..()

// Render all of the sprites of the items in the pile.
/obj/item/pile/update_overlays()
	. = ..()
	cut_overlays()
	if(length(items) <= 1)
		icon_state = null // we want an error icon to appear if this doesn't get qdel
		return
	// Only display the top items in the pile
	var/index_offset = min(PILE_MAX_ITEMS_LIMIT, length(items))
	for(var/index in 0 to index_offset - 1)
		add_item_overlay(items[index])

/*----------------------------/
/   PILE-SPECIFIC FUNCTIONS   /
/----------------------------*/

/// Renders the given item's sprite as an overlay.
/obj/item/pile/proc/add_item_overlay(obj/item/item)
	var/image/item_overlay = image(item.icon, icon_state = item.icon_state, pixel_x = rand(-10, 10), pixel_y = rand(-10, 10))
	var/matrix/transform = matrix()
	//transform.Turn(pick(0, 90, 180, 270))
	item_overlay.transform = transform
	add_overlay(item_overlay)

/// Callback used by show_radial_menu in [/obj/item/pile/attack_self].
/obj/item/pile/proc/check_menu(mob/living/user)
	return isliving(user) && !user.incapacitated()

/// Removes and returns all items in the pile.
/obj/item/pile/proc/remove_all_items()
	var/list/obj/item/removed_items = list()
	for(var/obj/item/item in items)
		removed_items += item
		items -= item
	return removed_items

/**
 * This is used to insert an individual item or a list of items into a pile.
 *
 * All items that are inserted have their angle and pixel offsets reset to zero.
 *
 * Arguments:
 * * mob/living/user - The user adding the item.
 * * item - Either an /obj/item or an /obj/item/pile that gets inserted into this pile.
 */
/obj/item/pile/proc/add_items(mob/living/user, obj/item/item)
	if(!isliving(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		return
	if(item.w_class > PILE_MAX_WEIGHT_CLASS)
		return
	if(length(items) >= PILE_MAX_ITEMS_LIMIT)
		return
	if(!istype(item, /obj/item))
		return

	var/items_to_add = list()
	// Exchange items to this pile from an existing pile.
	if(istype(item, /obj/item/pile))
		var/obj/item/pile/recycled_pile = item
		var/list/recycled_items = recycled_pile.items
		for(var/obj/item/recycled_item in recycled_items)
			items_to_add += recycled_pile.remove_item(recycled_item)
			if(length(items) >= PILE_MAX_ITEMS_LIMIT)
				break
	else
		// Add a single item to this pile.
		items_to_add += item

	for(var/obj/item/add_item in items_to_add)
		add_item.forceMove(src)
		add_item.pixel_x = 0
		add_item.pixel_y = 0
		var/matrix/transform = matrix()
		transform.Turn(0)
		add_item.transform = transform
		add_item.update_appearance()
		items += add_item
		items_to_add -= add_item

	// Piles bigger than 2 items are larger.
	if(length(items) > 2)
		w_class = WEIGHT_CLASS_NORMAL
	else
		w_class = WEIGHT_CLASS_SMALL

	update_appearance()
	return TRUE

/**
 * Removes and returns an item from the pile.
 * Removes items in FILO order. If an item arg is supplied, then it returns that specific item.
 * If the pile has one item left, the pile transpositions itself with that item.
 *
 * Arguments:
 * * mob/living/user - The user picking up the item.
 * * obj/item/item (optional) - Used by the radial menu for piles to remove specific items out of the pile.
**/
/obj/item/pile/proc/remove_item(mob/living/user, obj/item/item)
	if(!isliving(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		return

	if(!item)
		item = items[length(items)]
		if(!item)
			return

	items -= item

	update_appearance()

	if(length(items) == 1)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		var/obj/item/last_item = items[1]
		items -= last_item
		last_item.pickup(user)
		user.put_in_hands(last_item)
		qdel(src)

	return item

/// Removes all items from the pile, renders them in random positions, then deletes the emptied pile.
/obj/item/pile/proc/disperse_pile(mob/user)
	var/list/obj/item/removed_items = remove_all_items()
	for(var/obj/item/item in removed_items)
		item.forceMove(drop_location())
		item.pixel_x = rand(-16, 16)
		item.pixel_y = rand(-16, 16)
		var/matrix/transform = matrix()
		transform.Turn(pick(38, 68, 118, 168, 258))
		item.transform = transform
		item.update_appearance()
		item.SpinAnimation(pick(5, 10), 1, pick(1, 0))
		item.dropped(user)

	qdel(src)
	return TRUE
