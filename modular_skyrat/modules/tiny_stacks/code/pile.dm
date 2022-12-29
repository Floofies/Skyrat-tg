/obj/item/pile
	name = "pile of stuff"
	desc = "This is a bug. Please create an issue report on GitHub."
	resistance_flags = FLAMMABLE
	max_integrity = 50
	/// If set to TRUE, then all the atoms drop to the floor when thrown at a person.
	var/loose_pile = TRUE
	// Items contained in the pile.
	var/list/obj/item/atoms
	// Typepath of item which can be added to the pile.
	var/accepted_type
	// Sound emitted when removing one item from the pile.
	var/draw_sound


/obj/item/pile/Destroy()
	if (!isnull(atoms))
		QDEL_LIST(atoms)
	return ..()

/// When dropping a loose pile, this removes the items from the pile and then deletes the emptied /obj/item/pile.
/obj/item/pile/throw_impact(mob/living/target, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || !istype(target)) // was it caught or is the target not a living mob
		return .

	if(!throwingdatum?.thrower) // if a mob didn't throw it (need two people to play 52 pickup)
		return

	if(count_atoms() == 0)
		return

	if (!loose_pile)
		return

	for(var/obj/item/atom in fetch_atoms())
		atoms -= atom
		atom.forceMove(target.drop_location())
		atom.pixel_x = rand(-16, 16)
		atom.pixel_y = rand(-16, 16)
		var/matrix/Matrix = matrix()
		var/angle = pick(0, 90, 180, 270)
		Matrix.Turn(angle)
		atom.transform = Matrix
		atom.update_appearance()
		atom.SpinAnimation(10, 1)

	if(drop_sound)
		playsound(src, drop_sound, 50, TRUE)

	if(istype(src, /obj/item/pile))
		qdel(src)
		return

	update_appearance()

/**
 * This is used to insert a list of item atoms into a pile
 *
 * All items that are inserted have their angle and pixel offsets reset to zero.
 *
 * Arguments:
 * * atom - Either an item or a pile that gets inserted into the src
 */
/obj/item/pile/proc/insert(obj/item/atom)
	fetch_atoms()

	var/atoms_to_add = list()
	var/obj/item/pile/recycled_pile

	if(istype(atom, accepted_type))
		atoms_to_add += atom

	if(istype(atom, /obj/item/pile))
		recycled_pile = atom

		var/list/recycled_atoms = recycled_pile.fetch_atoms()

		for(var/obj/item/recycled_atom in recycled_atoms)
			atoms_to_add += recycled_atom
			recycled_atoms -= recycled_atom
			recycled_atom.moveToNullspace()
		qdel(recycled_pile)

	for(var/obj/item/add_atom in atoms_to_add)
		add_atom.forceMove(src)
		// reset the position and angle
		add_atom.pixel_x = 0
		add_atom.pixel_y = 0
		var/matrix/M = matrix()
		M.Turn(0)
		add_atom.transform = M
		add_atom.update_appearance()
		atoms += add_atom
		atoms_to_add -= add_atom
	update_appearance()

/**
 * Draws an item from the pile.
 *
 * Removes items in FIFO order unless an item arg is supplied, then it picks that specific item
 * and returns it (the item arg is used by the radial menu for piles to select
 * specific items out of the pile)
 * Arguments:
 * * mob/living/user - The user drawing the item.
 * * obj/item/atom (optional) - The item drawn from the pile
**/
/obj/item/pile/proc/draw(mob/living/user, obj/item/atom)
	if(!isliving(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		return

	if(count_atoms() == 0)
		to_chat(user, span_warning("There are no items in the pile!"))
		return

	var/list/tmp_atoms = fetch_atoms()

	atom = atom || tmp_atoms[1] //draw the item on top
	atoms -= atom

	update_appearance()

	if(draw_sound)
		playsound(src, draw_sound, 50, TRUE)

	return atom

/// Returns the items in the pile.
/obj/item/pile/proc/fetch_atoms()
	RETURN_TYPE(/list/obj/item)

	if (!isnull(atoms))
		return atoms

	atoms = list()

	return atoms

/// Returns the number of items in the pile.
/obj/item/pile/proc/count_atoms()
	return isnull(atoms) ? 0 : LAZYLEN(atoms)

/obj/item/pile/attack_self(mob/living/user)
	if(!isliving(user) || !user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		return

	var/list/radial = list()
	for(var/obj/item/atom in fetch_atoms())
		radial[atom] = image(icon = src.icon, icon_state = atom.icon_state)

	var/obj/item/choice = show_radial_menu(usr, src, radial, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE

	var/obj/item/selected_item = draw(user, choice)
	selected_item.pickup(user)
	user.put_in_hands(selected_item)

	if(count_atoms() == 1)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		var/obj/item/last_item = draw(user)
		last_item.pickup(user)
		user.put_in_hands(last_item)
		qdel(src) // Pile is empty now, so delete it.

/obj/item/pile/proc/check_menu(mob/living/user)
	return isliving(user) && !user.incapacitated()

/obj/item/pile/attackby(obj/item/item, mob/living/user, params)
	var/obj/item/atom

	if(istype(item, accepted_type))
		atom = item

	if(istype(atom, /obj/item/pile))
		var/obj/item/pile/existing_pile = atom
		existing_pile.insert(src)
		return

	return ..()
