/obj/item/reagent_containers/pill/attack_self(mob/user)
	. = ..()
	// TODO: Set up the extra stuff

/obj/item/pile/pills
	name = "pile of pills"
	desc = "A number of pills in a loose pile."
	w_class = WEIGHT_CLASS_SMALL
	accepted_type = /obj/item/reagent_containers/pill
