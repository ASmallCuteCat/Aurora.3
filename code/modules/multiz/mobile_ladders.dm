/obj/item/ladder_mobile
	name = "mobile ladder"
	desc = "A lightweight deployable ladder, which you can use to move up or down. Or alternatively, you can bash some faces in."
	icon_state = "mobile_ladder"
	item_state = "mobile_ladder"
	icon = 'icons/obj/multiz_items.dmi'
	contained_sprite = TRUE
	throw_range = 3
	force = 15
	w_class = ITEMSIZE_LARGE
	slot_flags = SLOT_BACK

/obj/item/ladder_mobile/proc/place_ladder(atom/A, mob/user)

	if (isopenturf(A))         //Place into open space
		var/turf/T = get_turf(A)
		var/turf/below_loc = GET_TURF_BELOW(T)
		if (!below_loc || (istype(/turf/space, below_loc)))
			to_chat(user, SPAN_NOTICE("Why would you do that?! There is only infinite space there..."))
			return
		user.visible_message(SPAN_WARNING("[user] begins to lower \the [src] into \the [A]."),
			SPAN_WARNING("You begin to lower \the [src] into \the [A]."))
		if (!handle_action(A, user))
			return
		// Create the lower ladder first. ladder/Initialize() will make the upper
		// ladder create the appropriate links. So the lower ladder must exist first.
		var/obj/structure/ladder/mobile/downer = new(below_loc)
		downer.allowed_directions = UP

		new /obj/structure/ladder/mobile(A)

		user.drop_from_inventory(src,get_turf(src))
		qdel(src)

	else if (istype(A, /turf/simulated/floor) || istype(A, /turf/unsimulated/floor))	//Place onto Floor
		var/turf/T = get_turf(A)
		var/turf/upper_loc = GET_TURF_ABOVE(T)
		if (!upper_loc || !isopenturf(upper_loc))
			to_chat(user, SPAN_NOTICE("There is something above. You can't deploy!"))
			return
		user.visible_message(SPAN_WARNING("[user] begins deploying \the [src] on \the [A]."),
			SPAN_WARNING("You begin to deploy \the [src] on \the [A]."))
		if (!handle_action(A, user))
			return
		// Ditto here. Create the lower ladder first.
		var/obj/structure/ladder/mobile/downer = new(A)
		downer.allowed_directions = UP

		new /obj/structure/ladder/mobile(upper_loc)

		user.drop_from_inventory(src, get_turf(src))
		qdel(src)

/obj/item/ladder_mobile/afterattack(atom/A, mob/user,proximity)
	if(!proximity)
		return

	place_ladder(A,user)

/obj/item/ladder_mobile/proc/handle_action(atom/A, mob/user)
	if(!do_after(user, 30, user))
		return FALSE
	if(!A || QDELETED(src) || QDELETED(user))
		// Shit was deleted during delay, call is no longer valid.
		return FALSE
	return TRUE

/obj/structure/ladder/mobile
	base_icon = "mobile_ladder"

/obj/structure/ladder/mobile/AltClick(mob/user)
	fold_up(user)

/obj/structure/ladder/mobile/verb/fold()
	set name = "Fold Ladder"
	set category = "Object"
	set src in oview(1)

	fold_up(usr)

/obj/structure/ladder/mobile/proc/fold_up(var/mob/user)
	if(!istype(user))
		return
	if(use_check_and_message(user))
		return

	user.visible_message(SPAN_NOTICE("\The [user] starts folding up \the [src]."),
		SPAN_NOTICE("You start folding up \the [src]."))

	if(!do_after(user, 30, src))
		return

	if(QDELETED(src))
		return

	var/obj/item/ladder_mobile/R = new /obj/item/ladder_mobile(get_turf(user))
	transfer_fingerprints_to(R)
	user.put_in_hands(R)

	user.visible_message(SPAN_NOTICE("\The [user] folds \the [src] up into \the [R]!"),
		SPAN_NOTICE("You fold \the [src] up into \the [R]!"))

	if(target_down)
		QDEL_NULL(target_down)
		qdel(src)
	else
		QDEL_NULL(target_up)
		qdel(src)
