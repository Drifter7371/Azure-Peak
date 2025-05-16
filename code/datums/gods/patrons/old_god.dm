/datum/patron/old_god
	name = "Psydon"
	domain = "God of Ontological Reality"
	desc = "The true God of everything, Psydon is maximally good - He created humen in his image to live in Psydonia, and defended the Azure Basin by sending the COMET SYON to defeat the rampaging archdemon."
	worshippers = "Fanatics and Nostalgists"
	associated_faith = /datum/faith/old_god
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T0,
	)
	confess_lines = list(
		"THERE IS ONLY ONE TRUE GOD!",
		"PSYDON YET LIVES! PSYDON YET ENDURES!",
		"REBUKE THE HERETICAL- PSYDON ENDURES!",
	)
