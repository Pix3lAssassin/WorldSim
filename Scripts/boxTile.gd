extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func init(locX: int, locY: int, sizeX: int, sizeY, elevation: float, oceanDepth) -> void:
	position.x = locX - sizeX / 2
	position.z = locY - sizeY / 2
	scale.y = (elevation / 4 - oceanDepth / 4 - 0.5) * -1
