//	Observer Pattern Implementation: Death
//		Registration type: /mob
//
//		Raised when: A mob is added to the dead_mob_list
//
//		Arguments that the called proc should expect:
//			/mob/dead: The mob that was added to the dead_mob_list

GLOBAL_DATUM_INIT(death_event, /singleton/observ/death, new)

/singleton/observ/death
	name = "Death"
	expected_type = /mob
