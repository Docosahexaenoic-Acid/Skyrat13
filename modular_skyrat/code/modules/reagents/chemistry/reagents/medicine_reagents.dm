/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC //Let's not cripple synth ops

/datum/reagent/medicine/lesser_syndicate_nanites
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/medicine/stimulants
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC //Syndicate developed 'accelerants' for synths?

/datum/reagent/medicine/neo_jelly
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC //Should synthetic miners not be able to use pens? Up for a debate probably but for now lets leave their contents in

/datum/reagent/medicine/lavaland_extract
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

/datum/reagent/medicine/leporazine
	process_flags = REAGENT_ORGANIC | REAGENT_SYNTHETIC

//REAGENTS FOR SYNTHS
/datum/reagent/medicine/system_cleaner
	name = "System Cleaner"
	description = "Neutralizes harmful chemical compounds inside synthetic systems."
	reagent_state = LIQUID
	color = "#F1C40F"
	taste_description = "ethanol"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	process_flags = REAGENT_SYNTHETIC

/datum/reagent/medicine/system_cleaner/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(-2*REM, 0)
	. = 1
	for(var/A in M.reagents.reagent_list)
		var/datum/reagent/R = A
		if(R != src)
			M.reagents.remove_reagent(R.type,1)
	..()

/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	description = "Repairs brain damage in synthetics."
	color = "#727272"
	taste_description = "metal"
	process_flags = REAGENT_SYNTHETIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/carbon/C)
	C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3*REM)
	if(prob(10))
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
	..()