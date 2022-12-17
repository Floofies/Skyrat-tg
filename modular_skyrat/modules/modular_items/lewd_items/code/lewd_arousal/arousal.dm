/mob/living/carbon/human/proc/adjust_arousal(arous = 0)
	if(stat >= DEAD || !client?.prefs?.read_preference(/datum/preference/toggle/erp))
		return

	var/arousal_flag = AROUSAL_NONE
	if(arousal >= AROUSAL_MEDIUM)
		arousal_flag = AROUSAL_FULL
	else if(arousal >= AROUSAL_LOW)
		arousal_flag = AROUSAL_PARTIAL

	if(arousal_status != arousal_flag) // Set organ arousal status
		arousal_status = arousal_flag
		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/target = src
			for(var/obj/item/organ/external/genital/target_genital in target.external_organs)
				if(!target_genital.aroused == AROUSAL_CANT)
					target_genital.aroused = arousal_status
					target_genital.update_sprite_suffix()
			target.update_body()

	arousal = clamp(arousal + arous, AROUSAL_MINIMUM, AROUSAL_LIMIT)

/*
* Lewd Examine for the Empath Quirk
* TODO: Convert this to a Component and use Signals instead of directly overriding.
*/

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	var/mob/living/examiner = user
	if(stat >= DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH) || src == examiner || !HAS_TRAIT(examiner, TRAIT_EMPATH))
		return

	if(examiner.client?.prefs?.read_preference(/datum/preference/toggle/erp))
		var/arousal_message
		switch(arousal)
			if(AROUSAL_MINIMUM_DETECTABLE to AROUSAL_LOW)
				arousal_message = span_purple("[p_they()] [p_are()] slightly blushed.") + "\n"
			if(AROUSAL_LOW to AROUSAL_MEDIUM)
				arousal_message = span_purple("[p_they()] [p_are()] quite aroused and seems to be stirring up lewd thoughts in [p_their()] head.") + "\n"
			if(AROUSAL_HIGH to AROUSAL_AUTO_CLIMAX_THRESHOLD)
				arousal_message = span_purple("[p_they()] [p_are()] aroused as hell.") + "\n"
			if(AROUSAL_AUTO_CLIMAX_THRESHOLD to INFINITY)
				arousal_message = span_purple("[p_they()] [p_are()] extremely excited, exhausting from entolerable desire.") + "\n"
		if(arousal_message)
			. += arousal_message
	else if(arousal > AROUSAL_MINIMUM_DETECTABLE)
		. += span_purple("[p_they()] [p_are()] slightly blushed.") + "\n"
