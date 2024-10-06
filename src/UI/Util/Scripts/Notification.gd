extends Panel

func _ready():
	$AnimationPlayer.play("Notification")

func set_notification_text(text):
	$Label.text = text
	var size_x = 200
	size_x += text.length() * 8
	custom_minimum_size.x = size_x

	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
