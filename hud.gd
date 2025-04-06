extends CanvasLayer

@onready var camera : = %PhysicalCamera3D
@onready var focal_length = $"Focal length"
@onready var focus_dist = $"focus dist"
@onready var aperture = $"aperture"
@onready var shutter_speed = $"shutter speed"
@onready var iso = $"ISO"

@onready var att : CameraAttributesPhysical = camera.attributes

func _on_character_body_3d_focal_length_changed() -> void:
	focal_length.text = "(scroll) Focal length: " + str(camera.attributes.frustum_focal_length) + "mm"


func _on_character_body_3d_focus_changed() -> void:
	focus_dist.text = "(ctrl) Focus distance: " + str(snapped(camera.attributes.frustum_focus_distance, 0.1)) + "m"

func _on_character_body_3d_iso_changed() -> void:
	iso.text = "(tab) ISO: " + str(snapped(att.exposure_sensitivity, 1))

func _on_character_body_3d_shutter_speed_changed() -> void:
	shutter_speed.text = "(alt) Shutter speed = 1/" + str(snapped(att.exposure_shutter_speed, 1))


func _on_character_body_3d_aperture_changed() -> void:
	aperture.text = "(meta) Aperture = f" + str(snapped(att.exposure_aperture, 0.1))
