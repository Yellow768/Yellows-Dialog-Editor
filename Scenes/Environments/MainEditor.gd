extends Control

var current_directory
var current_category_name

export(NodePath) var _dialog_editor_path
export(NodePath) var _category_list_path
export(NodePath) var _information_panel_path
export(NodePath) var _dialog_settings_tabs_path
export(NodePath) var _top_panel_path
export(NodePath) var _save_load_path


onready var DialogEditor = get_node(_dialog_editor_path)
onready var InformationPanel = get_node(_information_panel_path)
onready var DialogSettingsPanel = get_node(_dialog_settings_tabs_path)
onready var CategoryList = get_node(_category_list_path)
onready var TopPanel = get_node(_top_panel_path)
onready var SaveLoad = get_node(_save_load_path)

func _ready():
	OS.low_processor_usage_mode = true
	$EnvironmentIndex.environment_path = current_directory
	$EnvironmentIndex.index_categories()
	DialogEditor.connect("no_dialog_selected",self,"hide_InformationPanel")
	DialogEditor.connect("dialog_selected",self,"show_InformationPanel")
	$CategoryPanel.create_category_buttons($EnvironmentIndex.indexed_dialog_categories)


func hide_InformationPanel():
	InformationPanel.visible = false
	
func show_InformationPanel(dialog):
	InformationPanel.visible = true
	DialogSettingsPanel.load_dialog_settings(dialog)





func scan_cnpc_directory():
	if current_directory != null:
		var cnpc_directory = Directory.new()
		#scan_dialogs_directory(cnpc_directory)
		#scan_quest_directory(cnpc_directory)
		#scan_factions_directory(cnpc_directory)
	else:
		print("Editor loaded improperly. No directory selected")
	 



func scan_quest_directory(dir):
	pass
	
func scan_factions_directory(dir):
	pass



