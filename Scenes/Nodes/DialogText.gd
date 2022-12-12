extends TextEdit


func _ready():
	add_color_region("&r","",Color(1, 1, 1),true)
	add_color_region("&1","",Color(0.042969, 0.041458, 0.041458),true)
	add_color_region("&2","",Color(0, 0, 0.666667),true)
	add_color_region("&3","",Color(0, 0.666667, 0),true)
	add_color_region("&4","",Color(0.666667,0,0),true)
	add_color_region("&5","",Color(0.666667, 0, 0.666667),true)
	add_color_region("&6","",Color(1, 0.666667, 0))
	add_color_region("&7","",Color(0.666667,0.666667,0.666667),true)
	add_color_region("&8","",Color(0.333333, 0.333333, 0.333333),true)
	add_color_region("&9","",Color(0.333333, 0.333333, 1),true)
	add_color_region("&a","",Color(0.333333, 1, 0.333333),false)
	add_color_region("&b","",Color(0.333333, 1, 1),true)
	add_color_region("&c","",Color(1, 0.333333, 1),true)
	add_color_region("&d","",Color(0.333333, 1, 0.333333),true)
	add_color_region("&e","",Color(1, 1, 0.333333),true)
	add_color_region("&f","",Color(1, 1, 1),true)
	
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		release_focus()
