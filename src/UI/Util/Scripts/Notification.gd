extends PanelContainer

func _ready():
	$AnimationPlayer.play("Notification")

func set_notification_text(text,color):
	$Label.text = text
	$Label.modulate = color

	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
