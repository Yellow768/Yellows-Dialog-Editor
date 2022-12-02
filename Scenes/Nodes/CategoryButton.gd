extends Button

var index = 0

signal open_category_request

func _ready():
	pass
	


func _on_Button_pressed():
	emit_signal("open_category_request",self)
