extends GraphNode
class_name color_organizer
var node_type = "Color Organizer"
var text = "Color Organizer"
var color = Color(1,1,1,1)


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_filter = 2
	$TextEdit.custom_minimum_size.x = size.x
	$TextEdit.add_theme_font_size_override("font_size",size.y/8)
	self_modulate = color
	$TextEdit.text = text
	if color.get_luminance() > 0.5:
		$TextEdit.add_theme_color_override("font_color",Color(0,0,0,1))
	if color.get_luminance() <= 0.5:
		$TextEdit.add_theme_color_override("font_color",Color(1,1,1,1))

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize
	$TextEdit.custom_minimum_size.x = new_minsize.x
	$TextEdit.add_theme_font_size_override("font_size",new_minsize.y/8)


func _on_color_picker_button_color_changed(color):
	self_modulate = color
	$TextEdit.remove_theme_color_override("font_color")
	if color.get_luminance() > 0.5:
		$TextEdit.add_theme_color_override("font_color",Color(0,0,0,1))
	if color.get_luminance() <= 0.5:
		$TextEdit.add_theme_color_override("font_color",Color(1,1,1,1))
	


func _on_dragged(from, to):
	position_offset = to


func _on_raise_request():
	pass # Replace with function body.


func _on_node_selected():
	mouse_filter = 1
	resizable = true


func _on_node_deselected():
	mouse_filter = 2
	resizable = false

func save():
	var save_dict = {
		"node_type" : node_type,
		"filename": get_scene_file_path(),
		"position_offset.x" : position_offset.x,
		"position_offset.y" : position_offset.y,
		"min_size_x" : custom_minimum_size.x,
		"min_size_y" : custom_minimum_size.y,
		"color": ("0x"+String(self_modulate.to_html(false))).hex_to_int(),
		"min_size" : get_minimum_size(),
		"text" : $TextEdit.text
	}
	return save_dict
	


func _on_close_request():
	queue_free()
	
func delete_self(_useless_bool):
	queue_free()
