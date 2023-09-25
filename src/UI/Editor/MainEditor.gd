extends Control

var unsaved_change := false

@export var _dialog_editor_path: NodePath
@export var _category_list_path: NodePath
@export var _information_panel_path: NodePath
@export var _dialog_settings_tabs_path: NodePath
@export var _top_panel_path: NodePath



@onready var DialogEditor := get_node(_dialog_editor_path)
@onready var InformationPanel := get_node(_information_panel_path)
@onready var DialogSettingsPanel := get_node(_dialog_settings_tabs_path)
@onready var CategoryList := get_node(_category_list_path)
@onready var TopPanel := get_node(_top_panel_path)


func _ready():
	if !FileAccess.file_exists(CurrentEnvironment.current_directory+"/environment_settings.json"):
		FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.WRITE)
	var file := FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.READ)
	var test_json_conv := JSON.new()
	test_json_conv.parse(file.get_line())
	var loaded_list = test_json_conv.get_data()
	if loaded_list is Dictionary:
		$DialogList.all_loaded_dialogs = loaded_list
	else:
		push_warning("Loaded Dialogs List not valid.")
	var faction_choosers := get_tree().get_nodes_in_group("faction_access")
	var fact_loader := faction_loader.new()
	var fact_dict := fact_loader.get_faction_data(CurrentEnvironment.current_directory)
	for node in faction_choosers:
		node.load_faction_data(fact_dict)
	get_tree().auto_accept_quit = false
	
func _input(event : InputEvent):
	if event.is_action_pressed("add_dialog_at_mouse"):
		var new_dialog_node : dialog_node = GlobalDeclarations.DIALOG_NODE.instantiate()
		new_dialog_node.position_offset = get_local_mouse_position()
		DialogEditor.add_dialog_node(new_dialog_node)
	if event.is_action_pressed("create_response"):
		for dialog in DialogEditor.selected_nodes:
			dialog.add_response_node()
		for response in DialogEditor.selected_responses:
			response.add_new_connected_dialog()
	
	if event.is_action_pressed("focus_below"):
		match get_viewport().gui_get_focus_owner().get_name(): 
			"ResponseText":
				var response : response_node = get_viewport().gui_get_focus_owner().get_parent().get_parent().get_parent()
				if response.slot != response.parent_dialog.response_options.size()-1:
					response.parent_dialog.response_options[response.slot+1].set_focus_on_title()
			"TitleText":
				var dialog : dialog_node= get_viewport().gui_get_focus_owner().get_parent().get_parent().get_parent()
				dialog.set_focus_on_text()	
	if Input.is_action_just_pressed("focus_above"):
		match get_viewport().gui_get_focus_owner().get_name(): 
			"ResponseText":
				var response : response_node = get_viewport().gui_get_focus_owner().get_parent().get_parent().get_parent()
				if response.slot != 0:
					response.parent_dialog.response_options[response.slot-1].set_focus_on_title()
			"DialogText":
				var dialog : dialog_node = get_viewport().gui_get_focus_owner().get_parent().get_parent().get_parent()
				dialog.set_focus_on_title()
	if Input.is_action_just_pressed("focus_left"):
		
		if DialogEditor.selected_responses.size() == 1 && DialogEditor.selected_nodes.size() == 0:
			var response : response_node = DialogEditor.selected_responses[0]
			response.parent_dialog.set_focus_on_text()
		elif DialogEditor.selected_responses.size() == 0 && DialogEditor.selected_nodes.size() == 1:
			var dialog : dialog_node= DialogEditor.selected_nodes[0]
			if dialog.connected_responses.size() != 0:
				dialog.connected_responses[0].set_focus_on_title()
	if Input.is_action_just_pressed("focus_right"):
	
		if DialogEditor.selected_responses.size() == 1 && DialogEditor.selected_nodes.size() == 0:
			var response : response_node = DialogEditor.selected_responses[0]
			if response.connected_dialog != null:
				response.connected_dialog	.set_focus_on_text()
		elif DialogEditor.selected_responses.size() == 0 && DialogEditor.selected_nodes.size() == 1:
			var dialog : dialog_node = DialogEditor.selected_nodes[0]
			if dialog.response_options.size() != 0:
				dialog.response_options[0].set_focus_on_title()
				


func update_current_directory(new_path : String):
	CurrentEnvironment.current_directory = new_path
	var file_acess_group := get_tree().get_nodes_in_group("File Access")
	for node in file_acess_group:
		node.update_current_directory(new_path)

func update_current_category(category_name : String):
	CurrentEnvironment.current_category_name = category_name


func _on_DialogEditor_editor_cleared():
	InformationPanel.current_dialog = null

func export_dialog_list():
	var file := FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.WRITE)

	file.store_line(JSON.stringify($DialogList.all_loaded_dialogs))
	
func save_factions_list():
	var file := FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.WRITE)
	file.get_line()
	file.store_line("JSON.new().stringify($DialogList.all_loaded_dialogstes")

	
func give_factions_to_nodes(json : String):
	var file = FileAccess.open(json,FileAccess.READ)
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	var json_parsed : Dictionary = test_json_conv.get_data()
	file.close()
	if test_json_conv.error == OK:
		var faction_choosers := get_tree().get_nodes_in_group("faction_access")
		for node in faction_choosers:
			node.load_faction_data(json_parsed)
	else:
		printerr("Bad JSON File")


var is_quit_return_to_home := false

func _on_HomeButton_pressed():
	if !unsaved_change:
		get_parent().add_child(load("res://src/UI/LandingScreen.tscn").instantiate())
		queue_free()
	else:
		$UnsavedPanel.visible = true
		is_quit_return_to_home = true

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		is_quit_return_to_home = false
		if !unsaved_change:
			get_tree().quit()
		else:
			$UnsavedPanel.visible = true
					
func set_unsaved_changes(value:bool):
	unsaved_change = value



func _on_no_save_pressed():
	if is_quit_return_to_home:
		get_parent().add_child(load("res://src/UI/LandingScreen.tscn").instantiate())
		get_tree().auto_accept_quit = true
		queue_free()
		
	else:
		get_tree().quit()


func _on_save_and_close_pressed():
	$CategoryPanel.save_category_request()
	if is_quit_return_to_home:
		get_parent().add_child(load("res://src/UI/LandingScreen.tscn").instantiate())
		get_tree().auto_accept_quit = true
		queue_free()
	else:
		get_tree().quit()


func _on_cancel_pressed():
	$UnsavedPanel.visible = false


func _on_category_panel_category_succesfully_saved(_ignore):
	unsaved_change = false
