/obj/item/ammo_casing/attackby(obj/item/item, mob/living/user, params)
	// Add casing to pile.
	if(istype(item, /obj/item/pile/ammo_casings))
		var/obj/item/pile/ammo_casings/existing_pile = item
		existing_pile.insert(src)
		return

	// Create new casing pile.
	if(istype(item, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/casing = item
		var/obj/item/pile/ammo_casings/new_pile = new (drop_location())
		new_pile.insert(src)
		new_pile.insert(casing)
		new_pile.pixel_x = pixel_x
		new_pile.pixel_y = pixel_y

		if(!isturf(loc)) // Make a pile in our active hand.
			user.temporarilyRemoveItemFromInventory(src, TRUE)
			new_pile.pickup(user)
			user.put_in_active_hand(new_pile)
		return

	return ..()

/obj/item/pile/ammo_casings
	name = "pile of ammo casings"
	desc = "A number of ammo casings in a loose pile."
	w_class = WEIGHT_CLASS_SMALL
	accepted_type = /obj/item/ammo_casing
