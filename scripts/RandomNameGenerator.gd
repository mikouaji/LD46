const SYLABELS = ["ba","be","bi","bo","bu","by","ca","ce","ci","co","cu","cy","da","de","di","do","du","dy","fa","fe","fi","fo","fu","fy","ga","ge","gi","go","gu","gy","ha","he","hi","ho","hu","hy","ja","je","ji","jo","ju","jy","ka","ke","ki","ko","ku","ky","la","le","li","lo","lu","ly","ma","me","mi","mo","mu","my","na","ne","ni","no","nu","ny","pa","pe","pi","po","pu","py","qa","qe","qi","qo","qu","qy","ra","re","ri","ro","ru","ry","sa","se","si","so","su","sy","ta","te","ti","to","tu","ty","va","ve","vi","vo","vu","vy","wa","we","wi","wo","wu","wy","xa","xe","xi","xo","xu","xy","za","ze","zi","zo","zu","zy"]

const ENDINGS_PLANET = ["es", "or", "ir"]
const ENDINGS_PLANT = ["ea","ea","ue"]
const ENDINGS_ANIMAL = ["ro","go","bo"]

static func generate(type:String):
	match type:
		"PLANET": return generate_planet_name() 
		"PLANT": return generate_plant_name()
		"ANIMAL": return generate_animal_name()
		
static func generate_name(endings:Array, word_amount:int):
	randomize()
	var ending = endings[randi()%endings.size()]
	var name = ""
	for w in word_amount:
		var sylabels_amount = int(rand_range(1,5))
		for i in sylabels_amount:
			name += SYLABELS[randi()%SYLABELS.size()]
		name += " "
	name = name.trim_suffix(" ")
	name +=ending
	return name.capitalize()
	
static func generate_planet_name():
	return generate_name(ENDINGS_PLANET, 1)
static func generate_plant_name():
	return generate_name(ENDINGS_PLANT, 2)
static func generate_animal_name():
	return generate_name(ENDINGS_ANIMAL, 2)
