extends Panel

func _input(event):
	if event.is_action_released("control"):
		visible = !visible
