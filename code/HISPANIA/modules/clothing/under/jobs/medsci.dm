///Hispania MedSci Department Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//Resprite of RD Uniform

/obj/item/clothing/under/rank/research_director
	icon_state = "rd"
	item_state = "rd"
	item_color = "rd"
	hispania_icon = TRUE

/obj/item/clothing/under/rank/research_director/formal
	desc = "A formal uniform with a tie and a badge, it says Research Director"
	icon_state = "rd_black"
	item_color = "rd_black"

/obj/item/clothing/under/rank/research_director/formal/purple
	icon_state = "rd_purple"
	item_color = "rd_purple"
	species_restricted = list("exclude", "Grey", "Vox")


