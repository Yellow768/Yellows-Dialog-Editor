extends Control

var current_directory

export(NodePath) var _dialog_editor_path
export(NodePath) var _category_list_path
export(NodePath) var _information_panel_path
export(NodePath) var _dialog_settings_tabs_path


onready var DialogEditor = get_node(_dialog_editor_path)
onready var InformationPanel = get_node(_information_panel_path)
onready var DialogSettingsPanel = get_node(_dialog_settings_tabs_path)
onready var CategoryList = get_node(_category_list_path)

func _ready():
	OS.low_processor_usage_mode = true
	scan_cnpc_directory()
	DialogEditor.connect("no_dialog_selected",self,"hide_InformationPanel")
	DialogEditor.connect("dialog_selected",self,"show_InformationPanel")
	CategoryList.current_directory_path = current_directory


func hide_InformationPanel():
	InformationPanel.visible = false
	
func show_InformationPanel(dialog):
	InformationPanel.visible = true
	DialogSettingsPanel.load_dialog_settings(dialog)


func get_filelist(scan_dir : String, filter_exts : Array = []) -> Array:
	var my_files : Array = []
	var dir := Directory.new()
	if dir.open(scan_dir) != OK:
		printerr("Warning: could not open directory: ", scan_dir)
		return []

	if dir.list_dir_begin(true, true) != OK:
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += get_filelist(dir.get_current_dir() + "/" + file_name, filter_exts)
		else:
			if filter_exts.size() == 0:
				var json_pos = file_name.find(".json")
				file_name.erase(json_pos,5)
				if file_name.is_valid_integer():
					my_files.append(int(file_name))
			else:
				for ext in filter_exts:
					if file_name.get_extension() == ext:
						var json_pos = file_name.find(".json")
						file_name.erase(json_pos,5)
						if file_name.is_valid_integer():
							my_files.append(int(file_name))
		file_name = dir.get_next()
	return my_files


func scan_cnpc_directory():
	if current_directory != null:
		var cnpc_directory = Directory.new()
		scan_dialogs_directory(cnpc_directory)
		scan_quest_directory(cnpc_directory)
		scan_factions_directory(cnpc_directory)
	else:
		print("Editor loaded improperly. No directory selected")
	 

func scan_dialogs_directory(dir):
	var categories = []
	var numbers = []
	var highest_id = 0
	
	if dir.open(current_directory+"/dialogs") == OK:
		dir.list_dir_begin()
		var category_name = dir.get_next()
		while category_name != "":
			if dir.current_is_dir() && (category_name != "." && category_name != ".."):
				print("Found category "+category_name)
				categories.append(category_name)
			category_name = dir.get_next()
	
	numbers = get_filelist(current_directory+"/dialogs",["json"])
	numbers.sort()
	highest_id = numbers.back()
	
	$CategoryPanel.create_category_buttons(categories)
	print("starting id is: "+String(highest_id))


func scan_quest_directory(dir):
	pass
	
func scan_factions_directory(dir):
	pass



