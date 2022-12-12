extends Control

export(NodePath) var _dialog_editor_path
export(NodePath) var _category_list_path
export(NodePath) var _information_panel_path
export(NodePath) var _dialog_settings_tabs_path
export(NodePath) var _top_panel_path
export(NodePath) var _save_load_path
export(NodePath) var _environment_index_path

onready var DialogEditor = get_node(_dialog_editor_path)
onready var InformationPanel = get_node(_information_panel_path)
onready var DialogSettingsPanel = get_node(_dialog_settings_tabs_path)
onready var CategoryList = get_node(_category_list_path)
onready var TopPanel = get_node(_top_panel_path)
onready var SaveLoad = get_node(_save_load_path)
onready var EnvironmentIndex = get_node(_environment_index_path)

func _ready():
	OS.low_processor_usage_mode = true
	EnvironmentIndex.index_categories()
	refresh_category_list()
	
func _input(event):
	if event.is_action_pressed("add_dialog_at_mouse"):
		var new_dialog_node = DialogEditor.add_dialog_node(get_local_mouse_position())
		new_dialog_node.set_focus_on_title()
	if event.is_action_pressed("create_response"):
		for dialog in DialogEditor.selected_nodes:
			dialog.add_response_node()
	if event.is_action_pressed("focus_response_below"):
		if get_focus_owner().get_name() != "ResponseText":
			return
		else:
			var response = get_focus_owner().get_parent().get_parent().get_parent()
			if response.slot != response.parent_dialog.response_options.size():
				response.parent_dialog.response_options[response.slot].set_focus_on_title()		
	if Input.is_action_just_pressed("focus_response_above"):
		if get_focus_owner().get_name() != "ResponseText":
			return
		else:
			var response = get_focus_owner().get_parent().get_parent().get_parent()
			if response.slot != 1:
				response.parent_dialog.response_options[response.slot-2].set_focus_on_title()
				


func update_current_directory(new_path):
	CurrentEnvironment.current_directory = new_path
	var file_acess_group = get_tree().get_nodes_in_group("File Access")
	for node in file_acess_group:
		node.update_current_directory(new_path)

func update_current_category(category_name):
	CurrentEnvironment.current_category_name = category_name


func _on_DialogEditor_editor_cleared():
	InformationPanel.current_dialog = null



func refresh_category_list():
	$CategoryPanel.create_category_buttons($EnvironmentIndex.indexed_dialog_categories)
