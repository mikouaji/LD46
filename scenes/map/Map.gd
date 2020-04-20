extends TileMap

const VOID_CELL = 0;
const TILE_OFFSET = 64

var MAP_TILES = []

var creatures = 0
var creatures_max = 0
var plant_amount = 0
var animal_amount = 0
var newborns = []

func connect_events():
	connect("add_plant", $"../../CanvasLayer/GUI/PlanetInfo", "set_plants_value")
	connect("add_animal", $"../../CanvasLayer/GUI/PlanetInfo", "set_animals_value")
	connect("give_back_to_planet", get_parent(), "add_energy")

signal add_plant
signal add_animal
func add_creature(creature, tile = null):
	if tile == null:
		tile = get_random_tile_for_creature(creature)
	if tile !=null:
		match creature.type:
			Creature.TYPE_PLANT:
				plant_amount +=1
				emit_signal("add_plant", plant_amount)
			Creature.TYPE_ANIMAL:
				animal_amount +=1
				emit_signal("add_animal", animal_amount)	
		self.add_child(creature)
		creature.position = offset_coord(map_to_world(tile), true)
		creatures+=1
		creatures_max+=1

func add_newborn(creature, tile):
	newborns.push_back({
		"child":creature,
		"tile":tile,
	})

signal give_back_to_planet
func creature_died(creature, natural:bool):
	var child_index = get_children().find(creature)
	var child = get_child(child_index)
	if child:
		#animate death and after
		var energy = round(child.max_health/2)
		emit_signal("give_back_to_planet", energy)
		match creature.type:
			Creature.TYPE_ANIMAL:
				animal_amount -=1
				emit_signal("add_animal", animal_amount)
			Creature.TYPE_PLANT:
				plant_amount -=1
				emit_signal("add_plant", plant_amount)
		creatures -=1
		child.queue_free()

func offset_coord(coords, onoff:bool):
	if onoff:
		coords.x += TILE_OFFSET
		coords.y += TILE_OFFSET
	else:
		coords.x -= TILE_OFFSET
		coords.y -= TILE_OFFSET
	return coords

func get_random_tile_for_creature(creature):
	randomize()
	var searched = []
	while true:
		var tile = MAP_TILES[randi()%MAP_TILES.size()]
		if check_if_empty_tile(tile, creature.type):
			return tile
		else:
			searched.push_back(tile)
		if searched.size() == MAP_TILES.size():
			return null

func find_free_tile(tiles, type, my_tile):
	tiles.erase(my_tile)
	if tiles.size() <=0:
		return null
	randomize()
	var searched = []
	while true:
		var tile = tiles[randi()%tiles.size()]
		if check_if_empty_tile(tile, type):
			return tile
		else:
			searched.push_back(tile)
		if searched.size() == tiles.size():
			return null

func check_if_empty_tile(tile, type):
	var allowed
	match type:
		Creature.TYPE_ANIMAL:
			allowed = 2
		Creature.TYPE_PLANT:
			allowed = 1
	var specific_creatures = 0
	for child in get_children():
		if child is Creature:
			var its_tile = get_tile_for(child)
			if its_tile == tile:
				if child.type == type:
					specific_creatures +=1
	return specific_creatures < allowed 

func get_tile_for(creature):
	return get_tile_from_coords(offset_coord(creature.position, false))
	
func get_position_for(tile):
	return offset_coord(get_coords_from_tile(tile), true)

func get_tile_from_coords(coords:Vector2):
	return world_to_map(coords)
	
func get_coords_from_tile(tile:Vector2):
	return map_to_world(tile)
	
func get_tiles_around(tile:Vector2, radius: int, type):
	var circle = get_circle(radius)
	var tiles = []
	for c in circle:
		var new_y = c.y+tile.y
		var new_x = c.x+tile.x
		if abs(int(tile.y)%2) == 1 and abs(int(c.y)%2)==1:
			new_x +=1
		tiles.push_back(Vector2(new_x, new_y))
	tiles = filter_tiles_over_border(tiles)
	#another shader place
#	for t in tiles:
#		set_cell(t.x,t.y,3)
	return tiles

func get_empty_tiles_in_sight(tiles):
	for child in get_children():
		if child is Creature:
			var child_tile = get_tile_for(child)
			if tiles.has(child_tile):
				tiles.erase(child_tile)
	return tiles

func filter_tiles_over_border(tiles):
	var show = []
	for t in tiles:
		if MAP_TILES.has(t):
			show.push_front(t)
	return show

func get_creatures_in_tiles(tiles:Array):
	var found = []
	for child in get_children():
		if child is Creature:
			if tiles.has(get_tile_for(child)):
				found.push_back(child)
	return found

func init(RADIUS: int = 10):
	connect_events()

	var _void_tiles = draw_hex_circle(RADIUS+1, VOID_CELL)
	MAP_TILES = draw_hex_circle(RADIUS, -1)
	
	#add camera to map
	var player_cam = preload("res://scenes/camera/Camera.tscn").instance()
	self.add_child(player_cam)
	player_cam.init(RADIUS, self)
	pass
	
func draw_hex_circle(radius:int, tile_id:int):
	var tiles = get_circle(radius)
	for tile in tiles:
		randomize()
		set_cell(tile.x, tile.y, tile_id if tile_id !=-1 else (randi()%5) +1)
	return tiles
	

func get_hex_line(number:int, start:int , end:int):
	var gen_start = start - (ceil(abs(number)/2) * (-1))
	var gen_end = end + (ceil(abs(number)/2) * (-1))
	var xes = []
	for x in range(gen_start, gen_end):
		if not (abs(number%2)==1 and x==gen_end-1):
			xes.push_back(x)
	return xes
	
func get_circle(radius:int):
	var start = radius * (-1)
	var end = radius + 1
	var tiles = []
	for y in range(start,end):
		for x in get_hex_line(y, start, end):
			tiles.push_back(Vector2(x,y))
	return tiles
