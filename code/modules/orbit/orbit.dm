/datum/orbit
	var/atom/movable/orbiter
	var/atom/orbiting
	var/lock = TRUE
	var/turf/lastloc
	var/lastprocess

/datum/orbit/New(_orbiter, _orbiting, _lock)
	orbiter = _orbiter
	orbiting = _orbiting
	SSorbit.processing += src
	if (!orbiting.orbiters)
		orbiting.orbiters = list()
	orbiting.orbiters += src

	if (orbiter.orbiting)
		orbiter.stop_orbit()
	orbiter.orbiting = src
	Check()
	lock = _lock

//do not qdel directly, use stop_orbit on the orbiter. (This way the orbiter can bind to the orbit stopping)
/datum/orbit/Destroy(force = FALSE)
	SSorbit.processing -= src
	if (orbiter)
		orbiter.orbiting = null
		orbiter = null
	if (orbiting)
		if (orbiting.orbiters)
			orbiting.orbiters -= src
			if (!orbiting.orbiters.len)//we are the last orbit, delete the list
				orbiting.orbiters = null
		orbiting = null
	return ..()

/datum/orbit/proc/Check(turf/targetloc)
	if (!orbiter)
		qdel(src)
		return
	if (!orbiting)
		orbiter.stop_orbit()
		return
	if (!orbiter.orbiting) //admin wants to stop the orbit.
		orbiter.orbiting = src //set it back to us first
		orbiter.stop_orbit()
	lastprocess = world.time
	if (!targetloc)
		targetloc = get_turf(orbiting)
	if (!targetloc || (!lock && orbiter.loc != lastloc && orbiter.loc != targetloc))
		orbiter.stop_orbit()
		return
	orbiter.forceMove(targetloc)
	lastloc = orbiter.loc

/atom/movable/var/datum/orbit/orbiting = null
/atom/var/list/orbiters = null

//A: atom to orbit
//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir, useful for things to go "head first" like ghosts
//lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)

/atom/movable/proc/orbit(atom/A, radius = 10, rotation_speed = 20, pre_rotation = TRUE, lockinorbit = FALSE)
	if (!istype(A))
		return

	new/datum/orbit(src, A, lockinorbit)
	if (!orbiting) //something failed, and our orbit datum deleted itself
		return
	var/matrix/initial_transform = matrix(transform)

	//Head first!
	if (pre_rotation)
		var/matrix/M = matrix(transform)
		M.Turn(90)
		transform = M

	var/matrix/shift = matrix(transform)
	shift.Translate(0,radius)
	transform = shift

	SpinAnimation(rotation_speed, -1)

	//we stack the orbits up client side, so we can assign this back to normal server side without it breaking the orbit
	transform = initial_transform

/atom/movable/proc/stop_orbit()
	SpinAnimation(0,0)
	QDEL_NULL(orbiting)
