extends Panel

signal load_existing_category_request
signal import_category_request


export(NodePath) var animation_player_path
export(NodePath) var category_file_container_path
export(NodePath) var environment_index_path


var current_directory_path

onready var _animation_player = get_node(animation_player_path)
onready var _category_file_container = get_node(category_file_container_path)
onready var _EnvironmentIndex = get_node(environment_index_path)

var categoryPanelRevealed = false

func create_category_buttons(categories):
	for i in categories:
		var category_button = load("res://Scenes/Nodes/CategoryButton.tscn").instance()
		category_button.index = categories.find(i)
		category_button.text = i["category_name"]
		category_button.toggle_mode = true
		category_button.group  = load("res://Scenes/Environments/CategoryButtons.tres")
		category_button.connect("open_category_request",self,"_category_button_pressed")
		_category_file_container.add_child(category_button)
		





func _category_button_pressed(category_button):
	if _EnvironmentIndex.indexed_dialog_categories[category_button.index]["has_ydec"] == true:
		emit_signal("load_existing_category_request",category_button.text)
	else:
		emit_signal("import_category_request",category_button.text)


func _on_CategoryPanel_mouse_entered():
	if !categoryPanelRevealed:
		_animation_player.play("RevealCategoryPanel")
		categoryPanelRevealed = true
	



func _on_CategoryPanel_mouse_exited():
	if not Rect2(Vector2(),rect_size).has_point(get_local_mouse_position()):
		_animation_player.play_backwards("RevealCategoryPanel")
		categoryPanelRevealed = false
