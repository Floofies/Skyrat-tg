/// The component which moderately impairs a Mob's ability to hear chat/sounds.
/datum/component/bad_hearing
	/// The number of turfs, in a radius around the mob, in which it can hear sound.
	var/hearing_range = 6

/datum/component/bad_hearing/Initialize()
	// Only living Mobs can have bad hearing.
	if (!isliving(parent))
		stack_trace("Bad Hearing component added to [parent] ([parent?.type]) which is not a /mob/living subtype.")
		return COMPONENT_INCOMPATIBLE

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
/// Obfuscates or completely erases the heard message.
/datum/component/bad_hearing/proc/hear_badly(mob/living/source, list/message_args)
	SIGNAL_HANDLER

	// The Mob or Atom speaking
	var/mob/living/speaker = message_args[HEARING_SPEAKER]

	// Can always hear ourselves clearly, and can "hear" sign language clearly.
	if((speaker == parent) || HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	// Number of turfs between the hearing Mob and the speaker's turf.
	var/speaker_distance = get_dist(get_turf(parent), get_turf(speaker))

	// Can hear clearly if on the same turf as the speaker.
	if(speaker_distance == 0)
		return

	// Check for virtual speakers (aka hearing a message through a radio).
	var/radio_speaking = istype(speaker, /atom/movable/virtualspeaker)
	if (radio_speaking)
		var/atom/movable/virtualspeaker/virtualspeaker = speaker
		// Can hear our own radio clearly, and can hear radios same turf.
		if (virtualspeaker.radio.loc == source || speaker_distance == 1)
			return

	// Someone is speaking out of range, or whispering at a distance of more than one turf away.
	if((speaker_distance > hearing_range) || (speaker_distance > 1) && (message_args[HEARING_MESSAGE_MODE][WHISPER_MODE] == MODE_WHISPER))
		// Can't eavesdrop on whispers or hear any speech that is completely out of range.
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_ERASE_INPUT] = TRUE
		message_args[HEARING_MESSAGE_MODE][MODE_CUSTOM_SAY_EMOTE] = "[speaker.verb_say] something but you cannot hear [speaker.p_them()]."
		return

	// Can hear yelling clearly.
	if(SPAN_YELL in message_args[HEARING_SPANS])
		return

	// Can't hear speech clearly at a distance of more than one turf away.
	// Can't hear adjacent whispers clearly.
	message_args[HEARING_RAW_MESSAGE] = stars(message_args[HEARING_RAW_MESSAGE], 25)
	message_args[HEARING_MESSAGE] = message_args[HEARING_RAW_MESSAGE]
