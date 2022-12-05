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
	DialogEditor.connect("no_dialog_selected",self,"hide_InformationPanel")
	DialogEditor.connect("dialog_selected",self,"show_InformationPanel")
	$CategoryPanel.create_category_buttons($EnvironmentIndex.indexed_dialog_categories)


func hide_InformationPanel():
	InformationPanel.visible = false
	
func show_InformationPanel(dialog):
	InformationPanel.visible = true
	DialogSettingsPanel.load_dialog_settings(dialog)

func update_current_directory(new_path):
	CurrentEnvironment.current_directory = new_path
	var file_acess_group = get_tree().get_nodes_in_group("File Access")
	for node in file_acess_group:
		node.update_current_directory(new_path)

func update_current_category(category_name):
	CurrentEnvironment.current_category_name = category_name


func _on_DialogEditor_editor_cleared():
	DialogSettingsPanel.current_dialog = null
