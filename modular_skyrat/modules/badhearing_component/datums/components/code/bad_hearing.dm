/datum/component/bad_hearing
	/// The number of turfs, in a radius around the mob, in which it can hear sound.
	var/hearing_range = 6

/datum/component/bad_hearing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(hear_badly))
	RegisterSignal(parent, COMSIG_MOB_PLAYSOUND_LOCAL, PROC_REF(muffle_sound))

/datum/component/bad_hearing/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_HEAR, COMSIG_MOB_PLAYSOUND_LOCAL))

/// Signal handler for [COMSIG_MOB_PLAYSOUND_LOCAL]
/// Muffles all sounds for the mob hearing them vio increasing the distance multiplier.
/datum/component/bad_hearing/proc/muffle_sound(mob/living/source, list/sound_args)
	SIGNAL_HANDLER

	if(!isturf(sound_args[PLAYSOUND_LOCAL_SOURCE]))
		return
	sound_args[PLAYSOUND_LOCAL_MAX_DISTANCE] = hearing_range
	var/sound_distance = get_dist(get_turf(parent), sound_args[PLAYSOUND_LOCAL_SOURCE])
	if (sound_distance > hearing_range)
		// Can't hear the sound whatsoever if it's out of range.
		sound_args[PLAYSOUND_LOCAL_VOLUME] = 0
	else
		// Everything within range sounds quiet and muffled.
		sound_args[PLAYSOUND_LOCAL_VOLUME] = max(5, sound_args[PLAYSOUND_LOCAL_VOLUME] - 25)

/// Signal handler for [COMSIG_MOVABLE_HEAR]
/// This signal handler cancels and stars out messages for Bad Hearing.
/datum/component/bad_hearing/proc/hear_badly(mob/living/source, list/message_args)
	SIGNAL_HANDLER

	var/mob/living/speaker = message_args[HEARING_SPEAKER]
	// Do nothing to the message if we're the speaker or "hearing" sign language.
	if((speaker == parent) || HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	var/speaker_distance = get_dist(parent, get_turf(speaker))

	if (message_args[HEARING_RADIO_FREQ] && speaker_distance <= 1)
		return

	var/whispering = message_args[HEARING_MESSAGE_MODE][WHISPER_MODE] == MODE_WHISPER
	if(whispering && speaker_distance > 1 || speaker_distance > hearing_range)
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_EMOTE] = "[speaker.verb_say] something but you cannot hear [speaker.p_them()]."
	else if(whispering || speaker_distance <= 1)
		message_args[HEARING_RAW_MESSAGE] = stars(message_args[HEARING_RAW_MESSAGE], 25)
		message_args[HEARING_MESSAGE] = message_args[HEARING_RAW_MESSAGE]
