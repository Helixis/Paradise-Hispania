//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/living/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	// hide and freeze for the GC
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	gibs(loc, dna)
	QDEL_IN(src, 0)
	return TRUE

//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/living/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	new /obj/effect/decal/cleanable/ash(loc)
	// hide and freeze them while they get GC'd
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	QDEL_IN(src, 0)
	return TRUE

/mob/living/melt()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	// hide and freeze them while they get GC'd
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	QDEL_IN(src, 0)
	return TRUE

/mob/living/proc/can_die()
	return !(stat == DEAD || (status_flags & GODMODE))

// Returns true if mob transitioned from live to dead
// Do a check with `can_die` beforehand if you need to do any
// handling before `stat` is set
/mob/living/death(gibbed)
	if(!can_die())
		// Whew! Good thing I'm indestructible! (or already dead)
		return FALSE

	..()
	stat = DEAD

	timeofdeath = world.time
	create_log(ATTACK_LOG, "died[gibbed ? " (Gibbed)": ""]")

	SetDizzy(0)
	SetJitter(0)
	SetLoseBreath(0)

	if(!gibbed && deathgasp_on_death)
		emote("deathgasp", force = TRUE)

	if(mind && suiciding)
		mind.suicided = TRUE
	reset_perspective(null)
	hud_used?.reload_fullscreen()
	update_sight()
	update_action_buttons_icon()

	update_damage_hud()
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()
	if(!gibbed && !QDELETED(src))
		addtimer(CALLBACK(src, .proc/med_hud_set_status), DEFIB_TIME_LIMIT + 1)

	for(var/s in ownedSoullinks)
		var/datum/soullink/S = s
		S.ownerDies(gibbed, src)
	for(var/s in sharedSoullinks)
		var/datum/soullink/S = s
		S.sharerDies(gibbed, src)

	if(!gibbed)
		update_canmove()

	GLOB.alive_mob_list -= src
	GLOB.dead_mob_list += src
	if(mind)
		mind.store_memory("Time of death: [station_time_timestamp("hh:mm:ss", timeofdeath)]", 0)
		GLOB.respawnable_list += src

		if(mind.name && !isbrain(src)) // !isbrain() is to stop it from being called twice
			var/turf/T = get_turf(src)
			var/area_name = get_area_name(T)
			for(var/P in GLOB.dead_mob_list)
				var/mob/M = P
				if((M.client?.prefs.toggles2 & PREFTOGGLE_2_DEATHMESSAGE) && (isobserver(M) || M.stat == DEAD))
					to_chat(M, "<span class='deadsay'><b>[mind.name]</b> has died at <b>[area_name]</b>. (<a href='?src=[M.UID()];jump=\ref[src]'>JMP</a>)</span>")

	if(client)
		kill_CH() //We dead... clear any prepared abilities...

	if(SSticker && SSticker.mode)
		SSticker.mode.check_win()

	// u no we dead
	return TRUE

/mob/living/proc/delayed_gib()
	visible_message("<span class='danger'><b>[src]</b> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
	Weaken(15)
	do_jitter_animation(1000, -1)
	addtimer(CALLBACK(src, .proc/gib), rand(20, 100))
