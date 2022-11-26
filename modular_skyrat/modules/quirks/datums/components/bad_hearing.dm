/datum/component/bad_hearing

/datum/component/bad_hearing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(hear_badly))

/datum/component/bad_hearing/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)

/// Signal handler for [COMSIG_MOVABLE_HEAR]
/// This signal handler cancels and stars out messages for Bad Hearing.
/datum/component/bad_hearing/proc/hear_badly(mob/living/source, list/message_args)
	SIGNAL_HANDLER

	var/mob/living/speaker = message_args[HEARING_SPEAKER]
	// Do nothing to the message if we're the speaker or "hearing" sign language.
	if((speaker == parent) || HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	var/distance = get_dist(parent, get_turf(speaker))
	if(message_args[HEARING_MESSAGE_MODE][WHISPER_MODE] == MODE_WHISPER)
		if(distance <= 1)
			return
		// Can't hear whispering unless it's from an adjacent turf.
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_EMOTE] = "[speaker.verb_whisper] something but you cannot hear [speaker.p_them()]."
	else if(distance > 1)
		// Can't hear speech clearly unless it's from an adjacent turf.
		message_args[HEARING_RAW_MESSAGE] = stars(message_args[HEARING_RAW_MESSAGE], 25)
		message_args[HEARING_MESSAGE] = message_args[HEARING_RAW_MESSAGE]
