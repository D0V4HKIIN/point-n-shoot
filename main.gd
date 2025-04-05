@tool
extends Node3D

const trees = preload("res://tree.tscn")

@export var dist_between_trees = 2
@export var randomness = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	for x in range(-5, 5):
		for y in range(-5, 5):
			var tree : Node3D = trees.instantiate()
			tree.position.x = x * dist_between_trees + randf_range(-randomness, randomness)
			tree.position.z = y * dist_between_trees + randf_range(-randomness, randomness)
			tree.rotation.y = randf()
			add_child(tree)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
