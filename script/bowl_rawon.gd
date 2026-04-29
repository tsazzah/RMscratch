extends Node3D

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		body.nearby_object = self
		print("🟢 Player near bowl")

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		if body.nearby_object == self:
			body.nearby_object = null
			print("🔴 Player left bowl")
