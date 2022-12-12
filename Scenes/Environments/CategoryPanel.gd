extends Panel

signal load_existing_category_request
signal import_category_request
signal set_category_file_path

signal reveal_category_panel
signal hide_category_panel

export(NodePath) var animation_player_path
export(NodePath) var category_file_container_path
export(NodePath) var environment_index_path
export(NodePath) var category_importer_path


var current_directory_path

onready var _animation_player = get_node(animation_player_path)
onready var _category_file_container = get_node(category_file_container_path)
onready var _EnvironmentIndex = get_node(environment_index_path)
onready var _CategoryImporter = get_node(category_importer_path)

var categoryPanelRevealed = false

func _ready():
	rect_position = Vector2(-290,50)
	$VBoxContainer.visible = false
	$VBoxContainer/ScrollContainer.get_v_scrollbar().rect_scale.x = 0

func create_category_buttons(categories):

	for node in _category_file_container.get_children():
		node.queue_free()
	for i in categories:
		var category_button = load("res://Scenes/Nodes/CategoryButton.tscn").instance()
		category_button.index = categories.find(i)
		category_button.text = i["category_name"]
		category_button.toggle_mode = true
		category_button.group  = load("res://Scenes/Environments/CategoryButtons.tres")
		category_button.connect("open_category_request",self,"_category_button_pressed")
		category_button.connect("rename_category_request",_EnvironmentIndex,"rename_category")
		category_button.connect("reimport_category_request",self,"reimport_category_popup")
		category_button.connect("delete_category_request",self,"request_deletion_popup")
		_category_file_container.add_child(category_button)
	$VBoxContainer/ScrollContainer.ensure_control_visible($VBoxContainer/ScrollContainer/CategoryContainers.get_children().back())
	#$ScrollContainer.rect_size += Vector2(0,900) 
		


func _category_button_pressed(category_button):
	if category_button.text != CurrentEnvironment.current_category_name:
		if _EnvironmentIndex.get_category_has_ydec(category_button.text):
			
			emit_signal("load_existing_category_request",category_button.text)
			emit_signal("set_category_file_path")
		else:
			emit_signal("import_category_request",category_button.text)
			_animation_player.play_backwards("CategoryPanel")
			categoryPanelRevealed = false


func _on_CategoryPanel_mouse_entered():
	if !categoryPanelRevealed:
		emit_signal("reveal_category_panel")
		categoryPanelRevealed = true




func _on_CategoryPanel_mouse_exited():
	if not Rect2(Vector2(),rect_size).has_point(get_local_mouse_position()):
		emit_signal("hide_category_panel")
		categoryPanelRevealed = false





func _on_CreateNewCategory_pressed():
	var confirm_text_popup = load("res://Scenes/Environments/TextEnterConfirmTemplate.tscn").instance()
	confirm_text_popup.connect("confirmed_send_text",_EnvironmentIndex,"create_new_category")
	#confirm_text_popup.rect_position = OS.window_size/2
	$".".add_child(confirm_text_popup)
	confirm_text_popup.popup_centered()

func request_deletion_popup(deletion_name):
	var confirm_deletion_popup = load("res://Scenes/Environments/ConfirmDeletion.tscn").instance()
	confirm_deletion_popup.connect("confirmed",_EnvironmentIndex,"delete_category",[deletion_name])
	confirm_deletion_popup.dialog_text = "Are you sure you want to delete "+deletion_name+"?\nAll dialogs will be deleted."
	$".".add_child(confirm_deletion_popup)
	confirm_deletion_popup.popup_centered()

func reimport_category_popup(reimport_name):
	var confirm_reimport_popup = load("res://Scenes/Environments/ConfirmDeletion.tscn").instance()
	confirm_reimport_popup.connect("confirmed",_CategoryImporter,"reimport_category",[reimport_name])
	confirm_reimport_popup.dialog_text = "Are you want to reimport "+reimport_name+"?\nAll current dialog nodes will be permanently deleted.\n The category will create new nodes from the existing JSON files in the directory."
	$".".add_child(confirm_reimport_popup)
	confirm_reimport_popup.popup_centered()
