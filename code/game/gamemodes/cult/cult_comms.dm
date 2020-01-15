// Contains cult communion, guide, and cult master abilities
#define MARK_COOLDOWN

/datum/action/innate/cultcomm
	name = "Communion"
	button_icon_state = "cult_comms"
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/innate/cultcomm/IsAvailable()
	if(!iscultist(owner))
		return 0
	return ..()

/datum/action/innate/cultcomm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	cultist_commune(usr, input)

/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	user.whisper("O bidai nabora se[pick("'","`")]sma!", language = /datum/language/common)
	user.whisper(html_decode(message))
	var/title = "Acolyte"
	var/span = "cultitalic"
	if(user.mind && user.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER))
		span = "cultlarge"
		if(ishuman(user))
			title = "Master"
		else
			title = "Lord"
	else if(!ishuman(user))
		title = "Construct"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/mob/M in GLOB.mob_list)
		if(iscultist(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	log_say("[user.real_name]/[user.key] : [message]")

/mob/living/proc/cult_help()
	set category = "Cultist"
	set name = "How to Play Cult"
	var/text = ""
	text += "<center><font color='red' size=3><b><i>Tenets of the Dark One</i></b></font></center><br><br><br>"

	text += "<font color='red'><b>I. SECRECY</b></font><br>Your cult is a SECRET organization. Your success DEPENDS on keeping your cult's members and locations SECRET for as long as possible. This means that your tome should be hidden \
	in your bag and never brought out in public. You should never create runes where other crew might find them, and you should avoid using talismans or other cult magic with witnesses around.<br><br>"

	text += "<font color='red'><b>II. TOME</b></font><br>You start with a unique talisman in your bag. This supply talisman can be used 3 times, and creates starter equipment for your cult. The most critical of the talisman's functions is \
	the power to create a tome. This tome is your most important item and summoning one (in secret) is your FIRST PRIORITY. It lets you talk to fellow cultists and create runes, which in turn is essential to growing the cult's power.<br><br>"

	text += "<font color='red'><b>III. RUNES</b></font><br>Runes are powerful sources of cult magic. Your tome will allow you to draw runes with your blood. Those runes, when hit with an empty hand, will attempt to \
	trigger the rune's magic. Runes are essential for the cult to convert new members, create powerful minions, or call upon incredibly powerful magic. Some runes require more than one cultist to use.<br><br>"

	text += "<font color='red'><b>IV. TALISMANS</b></font><br>Talismans are a mobile source of cult magic that are NECESSARY to achieve success as a cult. Your starting talisman can produce certain talismans, but you will need \
	to use the -create talisman- rune (with ordinary paper on top) to get more talismans. Talismans are EXTREMELY powerful, therefore creating more talismans in a HIDDEN location should be one of your TOP PRIORITIES.<br><br>"

	text += "<font color='red'><b>V. GROW THE CULT</b></font><br>There are certain basic strategies that all cultists should master. STUN talismans are the foundation of a successful cult. If you intend to convert the stunned person \
	you should use cuffs or a talisman of shackling on them and remove their headset before they recover (it takes about 10 seconds to recover). If you intend to sacrifice the victim, striking them quickly and repeatedly with your tome \
	will knock them out before they can recover. Sacrificed victims will their soul behind in a shard, these shards can be used on construct shells to make powerful servants for the cult. Remember you need TWO cultists standing near a \
	conversion rune to convert someone. Your construct minions cannot trigger most runes, but they will count as cultists in helping you trigger more powerful runes like conversion or blood boil.<br><br>"

	text += "<font color='red'><b>VI. VICTORY</b></font><br>You have two ultimate goals as a cultist, sacrifice your target, and summon Nar-Sie. Sacrificing the target involves killing that individual and then placing \
	their corpse on a sacrifice rune and triggering that rune with THREE cultists. Do NOT lose the target's corpse! Only once the target is sacrificed can Nar-Sie be summoned. Summoning Nar-Sie will take nearly one minute \
	just to draw the massive rune needed. Do not create the rune until your cult is ready, the crew will receive the NAME and LOCATION of anyone who attempts to create the Nar-Sie rune. Once the Nar-Sie rune is drawn \
	you must gathered 9 cultists (or constructs) over the rune and then click it to bring the Dark One into this world!<br><br>"

	var/datum/browser/popup = new(usr, "mind", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/mob/living/proc/cult_master()
	set category = "Cultist"
	set name = "Assert Leadership"
	pollCultists(src)  // This proc handles the distribution of cult master actions

/datum/action/innate/cultmast
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/innate/cultmast/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER))
		return 0
	return ..()

/datum/action/innate/cultmast/finalreck
	name = "Final Reckoning"
	desc = "A single-use spell that brings the entire cult to the master's location."
	button_icon_state = "sintouch"

/datum/action/innate/cultmast/finalreck/Activate()
	for(var/i in 1 to 4)
		chant(i)
		var/list/destinations = list()
		for(var/turf/T in orange(1, owner))
			if(!is_blocked_turf(T, TRUE))
				destinations += T
		if(!LAZYLEN(destinations))
			to_chat(owner, "<span class='warning'>You need more space to summon the cult!</span>")
			return
		if(do_after(owner, 30, target = owner))
			for(var/datum/mind/B in SSticker.mode.cult)
				if(B.current && B.current.stat != DEAD)
					var/turf/mobloc = get_turf(B.current)
					switch(i)
						if(1)
							new /obj/effect/overlay/temp/cult/sparks(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 50, 1)
						if(2)
							new /obj/effect/overlay/temp/dir_setting/cult/phase/out(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 75, 1)
						if(3)
							new /obj/effect/overlay/temp/dir_setting/cult/phase(mobloc, B.current.dir)
							playsound(mobloc, "sparks", 100, 1)
						if(4)
							playsound(mobloc, 'sound/magic/exit_blood.ogg', 100, 1)
							if(B.current != owner)
								B.current.setDir(SOUTH)
								var/turf/final = pick(destinations)
								new /obj/effect/overlay/temp/cult/blood(final)
								addtimer(CALLBACK(B.current, /mob/.proc/reckon, final), 10)
		else
			return
	GLOB.reckoning_complete = TRUE
	Remove(owner)

/mob/proc/reckon(turf/final)
	new /obj/effect/overlay/temp/cult/blood/out(get_turf(src))
	forceMove(final)

/datum/action/innate/cultmast/finalreck/proc/chant(chant_number)
	switch(chant_number)
		if(1)
			owner.say("C'arta forbici!", language = /datum/language/common)
		if(2)
			owner.say("Pleggh e'ntrath!", language = /datum/language/common)
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 50, 1)
		if(3)
			owner.say("Barhah hra zar'garis!", language = /datum/language/common)
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 75, 1)
		if(4)
			owner.say("N'ath reth sh'yro eth d'rekkathnor!!!", language = /datum/language/common)
			playsound(get_turf(owner),'sound/magic/clockwork/narsie_attack.ogg', 100, 1)

/datum/action/innate/cultmast/cultmark
	name = "Mark Target"
	desc = "Marks a target for the cult."
	button_icon_state = "cult_mark"
	var/obj/effect/proc_holder/cultmark/CM
	var/cooldown = 0
	var/base_cooldown = 1200

/datum/action/innate/cultmast/cultmark/New()
	CM = new()
	CM.attached_action = src
	..()

/datum/action/innate/cultmast/cultmark/IsAvailable()
	if(!owner.mind || !owner.mind.has_antag_datum(ANTAG_DATUM_CULT_MASTER))
		return 0
	if(cooldown > world.time)
		if(!CM.active)
			owner << "<span class='cultlarge'><b>You need to wait [round((cooldown - world.time) * 0.1)] seconds before you can mark another target!</b></span>"
		return 0
	return ..()

/datum/action/innate/cultmast/cultmark/Destroy()
	QDEL_NULL(CM)
	return ..()

/datum/action/innate/cultmast/cultmark/Activate()
	CM.toggle(owner) //the important bit
	return TRUE

/obj/effect/proc_holder/cultmark
	active = FALSE
	ranged_mousepointer = 'icons/effects/cult_target.dmi'
	var/datum/action/innate/cultmast/cultmark/attached_action

/obj/effect/proc_holder/cultmark/Destroy()
	attached_action = null
	return ..()

/obj/effect/proc_holder/cultmark/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='cult'>You cease the marking ritual.</span>")
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to mark a target for your cult...</span>")

/obj/effect/proc_holder/cultmark/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		GLOB.blood_target = target
		var/area/A = get_area(target)
		attached_action.cooldown = world.time + attached_action.base_cooldown
		addtimer(CALLBACK(attached_action.owner, /mob.proc/update_action_buttons_icon), attached_action.base_cooldown)
		GLOB.blood_target_image = image('icons/effects/cult_target.dmi', target, "glow", ABOVE_MOB_LAYER)
		GLOB.blood_target_image.appearance_flags = RESET_COLOR
		GLOB.blood_target_image.pixel_x = -target.pixel_x
		GLOB.blood_target_image.pixel_y = -target.pixel_y
		for(var/datum/mind/B in SSticker.mode.cult)
			if(B.current && B.current.stat != DEAD && B.current.client)
				to_chat(B.current, "<span class='cultlarge'><b>Master [ranged_ability_user] has marked [GLOB.blood_target] in the [A.name] as the cult's top priority, get there immediately!</b></span>")
				B.current << pick(sound('sound/hallucinations/over_here2.ogg',0,1,75), sound('sound/hallucinations/over_here3.ogg',0,1,75))
				B.current.client.images += GLOB.blood_target_image
		attached_action.owner.update_action_buttons_icon()
		remove_ranged_ability("<span class='cult'>The marking rite is complete! It will last for 90 seconds.</span>")
		addtimer(CALLBACK(GLOBAL_PROC, .proc/reset_blood_target), 900, TIMER_OVERRIDE)
		return TRUE
	return FALSE

/proc/reset_blood_target()
	for(var/datum/mind/B in SSticker.mode.cult)
		if(B.current && B.current.stat != DEAD && B.current.client)
			if(GLOB.blood_target)
				to_chat(B.current,"<span class='cultlarge'><b>The blood mark has expired!</b></span>")
			B.current.client.images -= GLOB.blood_target_image
	QDEL_NULL(GLOB.blood_target)