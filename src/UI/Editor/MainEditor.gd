extends Control

export(NodePath) var _dialog_editor_path
export(NodePath) var _category_list_path
export(NodePath) var _information_panel_path
export(NodePath) var _dialog_settings_tabs_path
export(NodePath) var _top_panel_path



onready var DialogEditor = get_node(_dialog_editor_path)
onready var InformationPanel = get_node(_information_panel_path)
onready var DialogSettingsPanel = get_node(_dialog_settings_tabs_path)
onready var CategoryList = get_node(_category_list_path)
onready var TopPanel = get_node(_top_panel_path)


func _ready():
	OS.low_processor_usage_mode = true
	var file = File.new()
	if file.open(CurrentEnvironment.current_directory+"/environment_settings.json",File.READ) == OK:
		$DialogList.all_loaded_dialogs = parse_json(file.get_line())
		file.close()
	var faction_choosers = get_tree().get_nodes_in_group("faction_access")
	var fact_loader = faction_loader.new()
	var fact_dict = fact_loader.get_faction_data(CurrentEnvironment.current_directory)
	for node in faction_choosers:
		node.load_faction_data(fact_dict)
	
func _input(event):
	if event.is_action_pressed("add_dialog_at_mouse"):
		var new_dialog_node = GlobalDeclarations.DIALOG_NODE.instance()
		new_dialog_node.offset = get_local_mouse_position()
		DialogEditor.add_dialog_node(new_dialog_node)
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





func _on_DialogFileSystemIndex_category_deleted():
	pass # Replace with function body.


func export_dialog_list():
	var file = File.new()
	file.open(CurrentEnvironment.current_directory+"/environment_settings.json",File.WRITE)
	file.store_line(to_json($DialogList.all_loaded_dialogs))
	file.close()
	
func save_factions_list():
	var file = File.new()
	file.open(CurrentEnvironment.current_directory+"/environment_settings.json",File.WRITE)
	file.get_line()
	file.store_line("to_json($DialogList.all_loaded_dialogstes")
	file.close()


func import_faction_popup():
	var faction_loader = load("res://src/UI/Util/FactionLoader.tscn").instance()
	add_child(faction_loader)
	faction_loader.connect("faction_json_selected",self,"give_factions_to_nodes")
	faction_loader.popup()
	
func give_factions_to_nodes(json):
	print(json)
	var file = File.new()
	file.open(json,File.READ)
	var json_parsed = JSON.parse(file.get_as_text())
	file.close()
	if json_parsed.error == OK:
		var faction_choosers = get_tree().get_nodes_in_group("faction_access")
		for node in faction_choosers:
			node.load_faction_data(json_parsed)
	else:
		printerr("Bad JSON File")


func _on_FactionChange2_faction_id_changed():
	pass # Replace with function body.
