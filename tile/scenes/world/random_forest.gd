extends Node2D

enum RandomType {Random, Perlin}

var min_size: int = 20

@export var size: Vector2i = Vector2i(100, 100)

func _place_character(character: CharacterBody2D):
	while true:
		var x = randi_range(0, size.x)
		var y = randi_range(0, size.y)
		var pos = Vector2i(x,y)
		var tile = ground.get_cell_atlas_coords(pos)
		if tile != Vector2i(-1,-1):
			character.global_position = ground.map_to_local(pos)
			break

@export var random_type: RandomType = RandomType.Random
@onready var water: TileMapLayer = $water
@onready var trees: TileMapLayer = $trees
@onready var ground: TileMapLayer = $ground
@onready var bridges: TileMapLayer = $bridges

var water_tiles = {
	"collision": Vector2i(0, 0),
	"bridge": Vector2i(1, 0),
}

var ground_tiles = {
	"ground": Vector2i(1,1)
}

var trees_tiles = {
	"small_tree": Vector2i(0,0),
	"big_tree": Vector2i(1,0),
	"apple_tree": Vector2i(3,0)
}

var bridge_tiles = {
	"v_start": Vector2i(1, 0),
	"v_middle": Vector2i(1, 1),
	"v_end": Vector2i(1, 2),
	"h_start": Vector2i(2, 1),
	"h_middle": Vector2i(3, 1),
	"h_end": Vector2i(4, 1),
}

func _ready() -> void:
	for x in range(-1, size.x+2, 1):
		water.set_cell(Vector2i(x, -1), 0,Vector2i(0, 0))
		water.set_cell(Vector2i(x, size.y+1), 0,Vector2i(0, 0))
	for y in range(-1, size.y+2, 1):
		water.set_cell(Vector2i(-1, y), 0, Vector2i(0,0))
		water.set_cell(Vector2i(size.x+1, y), 0, Vector2i(0,0))
	match random_type:
		RandomType.Random:
			_random()
		RandomType.Perlin:
			_perlin()		

func _random() ->void:
	for x in size.x+1:
		for y in size.y+1:
			var tile: Vector2i = Vector2i(-1, -1)
			var tile_pos = Vector2i(x, y)
			if randf() < 0.8:
				tile = ground_tiles["ground"]
			if tile != Vector2i(-1, -1):
				ground.set_cell(tile_pos, 0, tile)
				if randf() < 0.1:
					var tree_types: Array = trees_tiles.keys()
					var tree_type: int = randi_range(0, trees_tiles.size()-1)
					var tree = trees_tiles[tree_types[tree_type]]
					trees.set_cell(tile_pos + Vector2i(0, -1), 0, tree)
			else:
				water.set_cell(tile_pos, 0, Vector2i(0,0))

func _perlin():
	var noise = FastNoiseLite.new()
	#noise.seed = randi_range(0, 9999)
	noise.frequency = 0.05
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 3
	noise.fractal_lacunarity = 2
	noise.fractal_gain = 1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	var map: Array[Array]
	for y in size.y+1:
		map.append([])
		map[y].resize(size.x+1)
		for x in size.x+1:
			map[y][x] = 0
	
	for x in size.x+1:
		for y in size.y+1:
			var val = noise.get_noise_2d(x, y)
			if val > 0:
				map[y][x] = 1
	
	var map_copy = recursive_labeling(map)
	map_copy = apply_threshold(map_copy, min_size)
	
	for x in size.x+1:
		for y in size.y+1:
			var tile_pos = Vector2i(x,y)
			if map_copy[y][x] > 0:
				ground.set_cell(tile_pos, 0, ground_tiles["ground"])
			else:
				water.set_cell(tile_pos, 0, water_tiles["collision"])
	build_bridges(map_copy)

func neighbours4(y, x):
	return [Vector2i(x, y-1), Vector2i(x, y+1), Vector2i(x-1, y), Vector2i(x+1, y)]

func fill(lb, label, y, x):
	lb[y][x] = label
	for vector in neighbours4(y, x):
		var ny = vector.y
		var nx = vector.x
		if ny > size.y or nx > size.x or ny < 0 or nx < 0:
			continue
		if lb[ny][nx]==-1:
			fill(lb, label, ny, nx)

func recursive_labeling(map):
	var map_copy: Array = map
	for y in map_copy.size():
		for x in map_copy[y].size():
			map_copy[y][x] *= -1
	var label = 0
	for y in map_copy.size():
		for x in map_copy[y].size():
			if map_copy[y][x]==-1:
				label +=1
				fill(map_copy, label, y, x)
	return map_copy

func count_area(map: Array[Array], x: int, y: int):
	if y < 0 or y>= map.size(): return 0
	if x < 0 or x>= map[y].size(): return 0
	var label = map[y][x]
	if label == 0:
		return 0
		
	var area = 0
	var visited = {}
	var queue = []
	
	queue.append(Vector2i(x, y))
	
	while queue.size() > 0:
		var current = queue.pop_front()
		visited[Vector2i(current.x, current.y)] = true
		area += 1
		for n in neighbours4(current.y, current.x):
			if n.y < 0 or n.y >= map.size(): continue
			if n.x < 0 or n.x >= map[n.y].size(): continue
			if map[n.y][n.x] == label and not visited.has(n):
				visited[n] = true
				queue.append(n)
	return area

func apply_threshold(map: Array[Array], threshold: int):
	var areas_cache = {}
	for y in map.size():
		for x in map[y].size():
			var label = map[y][x]
			if label > 0:
				if not areas_cache.has(label):
					areas_cache[label] = count_area(map, x, y)
				if areas_cache[label] < threshold:
					map[y][x] = 0
	return map

func distance(p1: Vector2i, p2: Vector2i) -> float:
	return ((p2.x-p1.x)**2 + (p2.y-p1.y)**2)**0.5
	
func link_island(
	island: int,
	all_bridges: Array,
	linked_inslands: Array,
	queue: Array
):
	if island not in linked_inslands:
		linked_inslands.append(island)
	for bridge in all_bridges:
		if bridge.i1 == island and bridge.i2 not in linked_inslands or \
			bridge.i2 == island and bridge.i1 not in linked_inslands:
			queue.append(bridge)
	queue.sort_custom(func(a, b): return a.dist < b.dist)

func build_bridges(map: Array[Array]):
	var dict_bridges = {}
	var dict_distances = {}
	
	for start_y in size.y+1:
		for start_x in size.x+1:
			var start = map[start_y][start_x]
			if start > 0:
				for end_y in range(start_y, size.y+1):
					for end_x in range(start_x, size.x+1):
						var end = map[end_y][end_x]
						if end > 0 and start != end and (start_x == end_x or start_y == end_y):
							var p1 = Vector2i(start_x, start_y)
							var p2 = Vector2i(end_x, end_y)
							var bridge = [min(start, end), max(start, end)]
							var dist = distance(p1, p2)
							if bridge not in dict_bridges:
								dict_bridges[bridge] = [p1, p2]
								dict_distances[bridge] = dist
							else:
								var old_dist = dict_distances[bridge]
								if dist < old_dist:
									dict_bridges[bridge] = [p1, p2]
									dict_distances[bridge] = dist
									
	var all_bridges = []
	for bridge in dict_bridges:
		all_bridges.append({
			"i1": bridge[0],
			"i2": bridge[1],
			"dist": dict_distances[bridge],
			"start": dict_bridges[bridge][0],
			"end": dict_bridges[bridge][1],
		})
	
	all_bridges.sort_custom(func(a, b): return a.dist < b.dist)
	
	var linked_inslands = []
	var linked_bridges = []
	var queue = []
	
	link_island(all_bridges[0].i1, all_bridges, linked_inslands, queue)
	
	while queue.size()>0:
		var nearest = queue[0]
		queue.pop_front()
		if nearest.i2 not in linked_inslands:
			linked_bridges.append(nearest)
			link_island(nearest.i2, all_bridges, linked_inslands, queue)
		elif nearest.i1 not in linked_inslands:
			linked_bridges.append(nearest)
			link_island(nearest.i1, all_bridges, linked_inslands, queue)
		
	for bridge in linked_bridges:
		if bridge.start.x == bridge.end.x:
			bridges.set_cell(bridge.start, 0, bridge_tiles["v_start"])
			for y in range(bridge.start.y+1, bridge.end.y):
				var pos = Vector2i(bridge.start.x, y)
				bridges.set_cell(pos, 0, bridge_tiles["v_middle"])
				water.set_cell(pos, 0, water_tiles["bridge"])
				
			bridges.set_cell(bridge.end, 0, bridge_tiles["v_end"])
		elif bridge.start.y == bridge.end.y:
			bridges.set_cell(bridge.start, 0, bridge_tiles["h_start"])
			for x in range(bridge.start.x+1, bridge.end.x):
				var pos = Vector2i(x, bridge.start.y)
				bridges.set_cell(pos, 0, bridge_tiles["h_middle"])
				water.set_cell(pos, 0, water_tiles["bridge"])
				
			bridges.set_cell(bridge.end, 0, bridge_tiles["h_end"])
