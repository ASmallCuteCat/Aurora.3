/datum/click_handler/build_mode
	flags = CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT
	var/dir

	var/list/build_modes
	var/list/build_buttons

	var/datum/build_mode/current_build_mode

/datum/click_handler/build_mode/New(var/mob/user)
	..()

	build_modes = list()
	for(var/mode_type in subtypesof(/datum/build_mode))
		var/datum/build_mode/build_mode = new mode_type(src)
		if(build_mode.permission_requirement)
			if(!check_rights(build_mode.permission_requirement, FALSE, user))
				continue
		build_modes += build_mode
		if(build_mode.the_default)
			current_build_mode = build_mode

	build_buttons = list()
	for(var/button_type in subtypesof(/obj/effect/bmode))
		var/obj/effect/bmode/build_button = new button_type(src)
		build_buttons += build_button

/datum/click_handler/build_mode/Destroy()
	QDEL_NULL(current_build_mode)

	QDEL_LIST(build_modes)
	QDEL_LIST(build_buttons)

	. = ..()

/datum/click_handler/build_mode/Enter()
	user.client.show_popup_menus = FALSE
	for(var/build_button in build_buttons)
		user.client.screen += build_button

/datum/click_handler/build_mode/Exit()
	user.client.show_popup_menus = TRUE
	for(var/build_button in build_buttons)
		user.client.screen -= build_button

/datum/click_handler/build_mode/OnDblClick(var/atom/A, var/params)
	OnClick(A, params) // We treat double-clicks as normal clicks

/datum/click_handler/build_mode/OnClick(var/atom/A, var/params)
	params = params2list(params)
	if(A in build_buttons)
		var/obj/effect/bmode/build_button = A
		build_button.OnClick(params)
	else
		current_build_mode.OnClick(A, params)
