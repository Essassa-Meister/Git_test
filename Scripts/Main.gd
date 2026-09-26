extends Node3D

@onready var ground_mesh: MeshInstance3D = $Ground/MeshInstance3D

func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load("res://Textures/grass_texture.png")
	material.uv1_scale = Vector3(12.0, 12.0, 1.0)
	material.roughness = 1.0
	ground_mesh.material_override = material
