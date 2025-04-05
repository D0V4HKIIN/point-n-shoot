@tool
extends Node3D

const tree1 = preload("res://trees/tree1.tscn")
const tree2 = preload("res://trees/tree2.tscn")
const tree3 = preload("res://trees/tree3.tscn")
const tree4 = preload("res://trees/tree4.tscn")
const tree5 = preload("res://trees/tree5.tscn")

const trees = [tree1, tree2, tree3, tree4, tree5]

const sparrow = preload("res://birb/Sparrow.glb")
const humming = preload("res://birb/Hummingbird.glb")
const western_blue = preload("res://birb/Western bluebird.glb")
const parrot = preload("res://birb/Parrot.glb")

const birds = [parrot, sparrow, humming, western_blue]

var random = RandomNumberGenerator.new()

func get_rand(v):
	return v[random.randi() % len(v)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random.randomize()
	var tree = get_rand(trees)
	var tree_scene = tree.instantiate()
	add_child(tree_scene)
	
	if randf_range(0, 1) < 0.3:
		var markers = tree_scene.get_node("markers").get_children()
		var bird_pos = get_rand(markers)
		
		var bird = get_rand(birds)
		var bird_scene = bird.instantiate()
		add_child(bird_scene)
		
		bird_scene.transform = bird_pos.transform



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
