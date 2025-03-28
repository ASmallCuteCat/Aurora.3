//asteroid cavern creatures
/mob/living/simple_animal/hostile/retaliate/cavern_dweller
	name = "cavern dweller"
	desc = "An alien creature that dwells in the tunnels of the asteroid, commonly found in the Romanovich Cloud."
	icon = 'icons/mob/npc/cavern.dmi'
	icon_state = "dweller" //icons from europa station
	icon_living = "dweller"
	icon_dead = "dweller_dead"
	ranged = 1
	smart_ranged = TRUE
	turns_per_move = 3
	organ_names = list("head", "central segment", "tail")
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	a_intent = I_HURT
	stop_automated_movement_when_pulled = 0
	meat_type = /obj/item/reagent_containers/food/snacks/dwellermeat
	mob_size = 12

	health = 60
	maxHealth = 60
	blood_type = "#006666"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "chomped"
	attack_sound = 'sound/weapons/bite.ogg'
	speed = 4
	projectiletype = /obj/projectile/beam/cavern
	projectilesound = 'sound/magic/lightningbolt.ogg'
	break_stuff_probability = 2

	emote_see = list("stares","hovers ominously","blinks")

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "cavern"

	flying = TRUE
	see_invisible = SEE_INVISIBLE_NOLIGHTING

/mob/living/simple_animal/hostile/retaliate/cavern_dweller/Allow_Spacemove(var/check_drift = 0)
	return 1

/obj/projectile/beam/cavern
	name = "electrical discharge"
	icon_state = "stun"
	damage_type = DAMAGE_BURN
	check_armor = ENERGY
	damage = 5

	muzzle_type = /obj/effect/projectile/muzzle/stun
	tracer_type = /obj/effect/projectile/tracer/stun
	impact_type = /obj/effect/projectile/impact/stun

/mob/living/simple_animal/hostile/retaliate/cavern_dweller/DestroySurroundings(var/bypass_prob = FALSE)
	if(stance != HOSTILE_STANCE_ATTACKING)
		return 0
	else
		..()

/obj/projectile/beam/cavern/on_hit(atom/target, blocked, def_zone)
	. = ..()

	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		var/shock_damage = rand(10,20)
		M.electrocute_act(shock_damage)

/mob/living/simple_animal/hostile/retaliate/minedrone
	name = "mining rover"
	desc = "A dilapidated mining rover, with the faded colors of the Sol Alliance. It looks more than a little lost."
	icon = 'icons/mob/npc/cavern.dmi'
	icon_state = "sadrone"
	icon_living = "sadrone"
	icon_dead = "sadrone_dead"
	speed = 5
	health = 60
	maxHealth = 60
	harm_intent_damage = 5
	ranged = 1
	smart_ranged = TRUE
	organ_names = list("core", "right fore wheel", "left fore wheel", "right rear wheel", "left rear wheel")
	blood_type = COLOR_OIL
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	attack_sound = /singleton/sound_category/punch_sound
	a_intent = I_HURT
	speak_emote = list("chirps","buzzes","whirrs")
	emote_hear = list("chirps cheerfully","buzzes","whirrs","hums placidly","chirps","hums")
	projectiletype = /obj/projectile/beam/plasmacutter
	projectilesound = 'sound/weapons/plasma_cutter.ogg'
	destroy_surroundings = FALSE
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	light_range = 10
	light_wedge = LIGHT_WIDE
	psi_pingable = FALSE

	faction = "sol"

	var/list/loot = list()
	var/ore_message = 0
	var/target_ore
	var/ore_count = 0
	var/list/found_turfs = list()
	var/scan_timer = 0

/mob/living/simple_animal/hostile/retaliate/minedrone/Initialize()
	. = ..()
	var/i = rand(1,6)
	while(i)
		loot += pick(/obj/item/ore/silver, /obj/item/ore/gold, /obj/item/ore/uranium, /obj/item/ore/diamond)
		i--

/mob/living/simple_animal/hostile/retaliate/minedrone/death()
	..(null,"is smashed into pieces!")
	var/T = get_turf(src)
	new /obj/effect/gibspawner/robot(T)
	spark(T, 3, GLOB.alldirs)
	for(var/obj/item/ore/O in loot)
		O.forceMove(src.loc)
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/minedrone/Life(seconds_per_tick, times_fired)
	..()
	if(ore_count<20)
		FindOre()
	else if(!scan_timer)
		// reusing vars is funny
		visible_message(SPAN_WARNING("\The [src] pings, \"Mineral hopper full.\""))
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		scan_timer = rand(90, 150) // Life() ticks, so 3-5 minutes
	else
		scan_timer--

/mob/living/simple_animal/hostile/retaliate/minedrone/proc/FindOre()
	if(enemies?.len)
		return

	setClickCooldown(attack_delay)
	if(target_ore && !(get_dist(src, target_ore) <= 10))
		target_ore = null

	for(var/obj/item/ore/O in oview(1, src))
		O.forceMove(src)
		loot += O
		ore_count++
		if(target_ore == O)
			target_ore = null
		if(!ore_message)
			ore_message = TRUE

	if(ore_message)
		visible_message(SPAN_NOTICE("\The [src] collects the ore into a metallic hopper."))
		ore_message = FALSE

	if(!target_ore)
		for(var/obj/item/ore/O in oview(7, src))
			target_ore = O
			break

	if(target_ore)
		GLOB.move_manager.move_to(src, target_ore, 1, speed)
	else if(found_turfs.len)
		for(var/turf/simulated/mineral/M in found_turfs)
			if(!QDELETED(M) || !M.mineral)
				found_turfs -= M
			else
				rapid = TRUE
				OpenFire(M)
				rapid = FALSE
				break

	if(!found_turfs.len && !scan_timer) // we do a little caching, it's called we do a little caching
		for(var/turf/simulated/mineral/M in oview(7, src))
			if(M.mineral)
				found_turfs |= M

		if(!found_turfs.len) // there's no ore left, let's not waste processing for a bit
			scan_timer = 30 // Life() ticks

	else if(scan_timer)
		scan_timer--

/mob/living/simple_animal/hostile/retaliate/minedrone/adjustToxLoss(var/damage)
	return

/mob/living/simple_animal/hostile/retaliate/minedrone/adjustOxyLoss(var/damage)
	return

/mob/living/simple_animal/hostile/retaliate/minedrone/adjustCloneLoss(var/damage)
	return

/mob/living/simple_animal/hostile/retaliate/minedrone/adjustHalLoss(var/damage)
	return

/mob/living/simple_animal/hostile/retaliate/minedrone/fall_impact()
	visible_message(SPAN_DANGER("\The [src] bounces harmlessly on its inflated wheels."))
	return FALSE

/mob/living/simple_animal/hostile/retaliate/minedrone/get_bullet_impact_effect_type(var/def_zone)
	return BULLET_IMPACT_METAL
