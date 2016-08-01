#define COMMANDED_HEAL 8//we got healing powers yo
#define COMMANDED_HEALING 9

/mob/living/simple_animal/hostile/commanded/nanomachine
	name = "swarm"
	desc = "a cloud of tiny, tiny robots."
	icon = 'icons/mob/critter.dmi'
	icon_state = "blobsquiggle_grey"
	attacktext = "swarmed"
	health = 10
	maxHealth = 10
	var/regen_time = 0
	melee_damage_lower = 1
	melee_damage_upper = 2
	var/emergency_protocols = 0
	known_commands = list("stay", "stop", "attack", "follow", "heal", "emergency protocol")

	response_help = "waves their hands through"
	response_harm = "hits"
	response_disarm = "fans at"

/mob/living/simple_animal/hostile/commanded/nanomachine/Life()
	regen_time++
	if(regen_time == 2 && health < maxHealth) //slow regen
		regen_time = 0
		health++
	. = ..()
	if(.)
		switch(stance)
			if(COMMANDED_HEAL)
				if(!target)
					target = FindTarget(COMMANDED_HEAL)
				move_to_heal()
			if(COMMANDED_HEALING)
				heal()

/mob/living/simple_animal/hostile/commanded/nanomachine/death()
	..(null,"Dissipates into thin air")
	qdel(src)

/mob/living/simple_animal/hostile/commanded/nanomachine/proc/move_to_heal()
	if(!target)
		return 0
	walk_to(src,target,1,move_to_delay)
	if(Adjacent(target))
		stance = COMMANDED_HEALING

/mob/living/simple_animal/hostile/commanded/nanomachine/proc/heal()
	if(health <= 3 && !emergency_protocols) //dont die doing this.
		return 0
	if(!target)
		return 0
	if(!Adjacent(target) || SA_attackable(target))
		stance = COMMANDED_HEAL
		return 0
	if(target.stat || target.health >= target.maxHealth) //he's either dead or healthy, move along.
		allowed_targets -= target
		target = null
		stance = COMMANDED_HEAL
		return 0
	src.visible_message("\The [src] glows green for a moment, healing \the [target]'s wounds.")
	health -= 3
	target.adjustBruteLoss(-5)
	target.adjustFireLoss(-5)

/mob/living/simple_animal/hostile/commanded/nanomachine/misc_command(var/mob/speaker,var/text)
	if(stance != COMMANDED_HEAL || stance != COMMANDED_HEALING) //dont want attack to bleed into heal.
		allowed_targets = list()
		target = null
	if(findtext(text,"heal")) //heal shit pls
		if(findtext(text,"me")) //assumed want heals on master.
			target = speaker
			stance = COMMANDED_HEAL
			return 1
		var/list/targets = get_targets_by_name(text)
		if(targets.len > 1 || !targets.len)
			src.say("ERROR. TARGET COULD NOT BE PARSED.")
			return 0
		target = targets[1]
		stance = COMMANDED_HEAL
		return 1
	if(findtext(text,"emergency protocol"))
		if(findtext(text,"deactivate"))
			if(emergency_protocols)
				src.say("EMERGENCY PROTOCOLS DEACTIVATED.")
			emergency_protocols = 0
			return 1
		if(findtext(text,"activate"))
			if(!emergency_protocols)
				src.say("EMERGENCY PROTOCOLS ACTIVATED.")
			emergency_protocols = 1
			return 1
		if(findtext(text,"check"))
			src.say("EMERGENCY PROTOCOLS [emergency_protocols ? "ACTIVATED" : "DEACTIVATED"].")
			return 1
	return 0