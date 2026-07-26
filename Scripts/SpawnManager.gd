extends Node

@export var Player_SpawnPos : Node3D
@export var Player_Prefab : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if Player_Prefab == null:
		push_error("Player Prefab is missing from the Inspector!")
		return
		
	var playerInstance = Player_Prefab.instantiate() as CharacterBody3D 
		
	playerInstance.global_position=Player_SpawnPos.global_position
	add_child(playerInstance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
