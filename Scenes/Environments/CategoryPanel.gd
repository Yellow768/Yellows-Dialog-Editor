extends Panel

export(NodePath) var animation_player_path
export(NodePath) var category_file_container_path
export(String) var current_directory_path

onready var _animation_player = get_node(animation_player_path)
onready var _category_file_container = get_node(category_file_container_path)

var categoryPanelRevealed = false

func create_category_buttons(categories):
	for i in categories:
		var category_button = Button.new()
		category_button.text = i
		category_button.toggle_mode = true
		category_button.group  = load("res://Scenes/Environments/CategoryButtons.tres")
		category_button.connect("pressed",self,"_category_button_pressed")
		_category_file_container.add_child(category_button)
		


func search_through_category(category_name : String):
	var category_dir = Directory.new()
	category_dir.open(current_directory_path+"/"+category_name)


func _category_button_pressed(button):
	search_through_category(button.text)


func _on_CategoryPanel_mouse_entered():
	if !categoryPanelRevealed:
		_animation_player.play("RevealCategoryPanel")
		categoryPanelRevealed = true
	



func _on_CategoryPanel_mouse_exited():
	if not Rect2(Vector2(),rect_size).has_point(get_local_mouse_position()):
		_animation_player.play_backwards("RevealCategoryPanel")
		categoryPanelRevealed = false
