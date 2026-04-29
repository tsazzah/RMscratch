extends Area3D

var player_in_range = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.nearby_interactable = self

func _on_body_exited(body):
	if body.is_in_group("player"):
		if body.nearby_interactable == self:
			body.nearby_interactable = null


func interact(player):
	print("INTERACTED WITH:", name)
