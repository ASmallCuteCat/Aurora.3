/datum/random_map/noise/ore
	descriptor = "ore distribution map"
	var/deep_val = 0.8              // Threshold for deep metals, set in new as percentage of cell_range.
	var/rare_val = 0.7              // Threshold for rare metal, set in new as percentage of cell_range.
	var/chunk_size = 4              // Size each cell represents on map
	var/has_phoron = FALSE 			// For lore reasons: phoron is only found in certain places and we are running out of it

/datum/random_map/noise/ore/New()
	rare_val = cell_range * rare_val
	deep_val = cell_range * deep_val
	..()

/datum/random_map/noise/ore/check_map_sanity()

	var/rare_count = 0
	var/surface_count = 0
	var/deep_count = 0

	// Increment map sanity counters.
	for(var/value in map)
		if(value < rare_val)
			surface_count++
		else if(value < deep_val)
			rare_count++
		else
			deep_count++
	// Sanity check.
	if(surface_count < MIN_SURFACE_COUNT)
		admin_notice(SPAN_DANGER("Insufficient surface minerals. Rerolling..."), R_DEBUG)
		return 0
	else if(rare_count < MIN_RARE_COUNT)
		admin_notice(SPAN_DANGER("Insufficient rare minerals. Rerolling..."), R_DEBUG)
		return 0
	else if(deep_count < MIN_DEEP_COUNT)
		admin_notice(SPAN_DANGER("Insufficient deep minerals. Rerolling..."), R_DEBUG)
		return 0
	else
		return 1

/datum/random_map/noise/ore/apply_to_turf(var/x,var/y)

	var/tx = ((origin_x-1)+x)*chunk_size
	var/ty = ((origin_y-1)+y)*chunk_size

	for(var/i=0,i<chunk_size,i++)
		for(var/j=0,j<chunk_size,j++)
			var/turf/T = locate(tx+j, ty+i, origin_z)
			if(!istype(T) || !T.has_resources)
				continue
			if(!priority_process)
				CHECK_TICK
			T.resources = list()
			T.resources[ORE_SAND] = rand(3,5)
			T.resources[ORE_COAL] = rand(3,5)

			var/tmp_cell
			TRANSLATE_AND_VERIFY_COORD(x, y)

			if(tmp_cell < rare_val)      // Surface metals.
				T.resources[ORE_IRON] =     rand(RESOURCE_HIGH_MIN, RESOURCE_HIGH_MAX)
				T.resources[ORE_GOLD] =     rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources[ORE_SILVER] =   rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources[ORE_URANIUM] =  rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources[ORE_DIAMOND] =  0
				if(has_phoron)
					T.resources[ORE_PHORON] =   0
				T.resources[ORE_PLATINUM] =   0
				T.resources[ORE_HYDROGEN] = 0
			else if(tmp_cell < deep_val) // Rare metals.
				T.resources[ORE_GOLD] =     rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources[ORE_SILVER] =   rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources[ORE_URANIUM] =  rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				if(has_phoron)
					T.resources[ORE_PHORON] =   rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources[ORE_PLATINUM] =   rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources[ORE_HYDROGEN] = 0
				T.resources[ORE_DIAMOND] =  0
				T.resources[ORE_IRON] =     0
			else                             // Deep metals.
				T.resources[ORE_URANIUM] =  rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources[ORE_DIAMOND] =  rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				if(has_phoron)
					T.resources[ORE_PHORON] =   rand(RESOURCE_LOW_MIN, RESOURCE_LOW_MAX)
				T.resources[ORE_PLATINUM] =   rand(RESOURCE_HIGH_MIN, RESOURCE_HIGH_MAX)
				T.resources[ORE_HYDROGEN] = rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				if(prob(40)) // A medium chance for these useful mats to appear in very small quantities
					T.resources[ORE_IRON] =     rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
					T.resources[ORE_GOLD] =     rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
					T.resources[ORE_SILVER] =   rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				else
					T.resources[ORE_IRON] =     0
					T.resources[ORE_GOLD] =     0
					T.resources[ORE_SILVER] =   0
	return

/datum/random_map/noise/ore/get_map_char(var/value)
	if(value < rare_val)
		return "S"
	else if(value < deep_val)
		return "R"
	else
		return "D"

/datum/random_map/noise/ore/rich
	deep_val = 0.7
	rare_val = 0.5

/datum/random_map/noise/ore/phoron
	has_phoron = TRUE

/datum/random_map/noise/ore/rich/phoron
	has_phoron = TRUE
