extends Node

signal save_category_request
signal clear_editor_request

export(NodePath) var _main_program_path
export(NodePath) var _dialog_list_vbox_path
export(NodePath) var _dialog_editor_path

var current_directory
var imported_dialogs = []

onready var MainProgram = get_node(_main_program_path)
onready var DialogButtonList = get_node(_dialog_list_vbox_path)
onready var DialogEditor = get_node(_dialog_editor_path)

func _ready():
	current_directory = MainProgram.current_directory


func import_category(category_name):
	
	emit_signal("save_category_request")
	emit_signal("clear_editor_request")
	var dir_search = DirectorySearch.new()
	var files = dir_search.scan_all_subdirectories(current_directory+"/dialogs/"+category_name,["json"])
	if files.size() == 0 :
		var newFile = File.new()
		newFile.open(current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec",File.WRITE)
		newFile.close()
	else:
		imported_dialogs = []
		var current_dialog = File.new()
		for file in files:
			current_dialog.open(current_directory+"/dialogs/"+category_name+"/"+file,File.READ)
			var dialog_file_text = current_dialog.get_as_text()
			while(current_dialog.get_position() < current_dialog.get_len()):
				var current_line = current_dialog.get_line()
				if '"DialogShowWheel": ' in current_line or '"DialogHideNPC"' in current_line or '"DecreaseFaction1Points"' in current_line or '"DecreaseFaction2Points"' in current_line or '"BeenRead"' in current_line or '"DialogDisableEsc"' in current_line:
					var replace_line = current_line
					replace_line = current_line.replace("0b","0")
					replace_line = replace_line.replace("1b","1")
					dialog_file_text = dialog_file_text.replace(current_line,replace_line)
				if '"TimePast"' in current_line or '"Time' in current_line:
					var replace_line = current_line
					replace_line = current_line.replace("L","")
					dialog_file_text = dialog_file_text.replace(current_line,replace_line)
			if JSON.parse(dialog_file_text).error == OK:
				var json_result = JSON.parse(dialog_file_text).result
				imported_dialogs.append(json_result)
			else:
				printerr("Invalid Dialog JSON "+file+", skipping")
		imported_dialogs.sort_custom(self,"sort_array_by_dialog_title")
		create_initial_dialog_tree_buttons(imported_dialogs)

	
func create_initial_dialog_tree_buttons(all_dialogs):
	for i in all_dialogs.size():
		var dialog_button = Button.new()
		dialog_button.text = all_dialogs[i]["DialogTitle"]
		dialog_button.connect("pressed",self,"create_tree_from_inital_dialog",[dialog_button])
		DialogButtonList.add_child(dialog_button)	
	$PopupPanel.popup()
	
func sort_array_by_dialog_title(a,b):
	if a["DialogTitle"] != b["DialogTitle"]:
		return a["DialogTitle"] < b["DialogTitle"]
	else:
		return a["DialogTitle"]  < b["DialogTitle"] 


func create_tree_from_inital_dialog(button_chosen):
	var index = DialogButtonList.get_children().find(button_chosen)
	
	var initial_dialog = create_dialog_from_json_array(index,Vector2(300,300))
	create_dialogs_from_responses(initial_dialog)
	$PopupPanel.visible = false
	
var loaded_dialog_nodes = []

func create_dialog_from_json_array(index,offset):
	
	var new_node = DialogEditor.add_dialog_node(offset)
	var current_json = imported_dialogs[index]
	new_node.dialog_title = imported_dialogs[index]["DialogTitle"]
	new_node.dialog_id = current_json["DialogId"]
	new_node.text = current_json["DialogText"]
	new_node.disable_esc = bool(current_json["DialogDisableEsc"])
	new_node.show_wheel = bool(current_json["DialogShowWheel"])
	new_node.start_quest = current_json["DialogQuest"]
	new_node.min_level_availability = current_json["AvailabilityMinPlayerLevel"]
	new_node.time_availability = current_json["AvailabilityDayTime"]
	var id = ["","2","3","4"]
	for i in 4:
		new_node.quest_availabilities[i].quest_id = current_json["AvailabilityQuest"+id[i]+"Id"]
		new_node.quest_availabilities[i].availability_type = current_json["AvailabilityQuest"+id[i]]
		new_node.dialog_availabilities[i].dialog_id = current_json["AvailabilityDialog"+id[i]+"Id"]
		new_node.dialog_availabilities[i].availability_type = current_json["AvailabilityDialog"+id[i]]
	for i in 2:
		new_node.scoreboard_availabilities[i].objective_name = current_json["AvailabilityScoreboard"+id[i]+"Objective"]
		new_node.scoreboard_availabilities[i].value = current_json["AvailabilityScoreboard"+id[i]+"Value"]
		new_node.scoreboard_availabilities[i].comparison_type = current_json["AvailabilityScoreboard"+id[i]+"Type"]
		
		new_node.faction_availabilities[i].faction_id = current_json["AvailabilityFaction"+id[i]+"Id"]
		new_node.faction_availabilities[i].stance_type = current_json["AvailabilityFaction"+id[i]+"Stance"]
		new_node.faction_availabilities[i].availability_operator = current_json["AvailabilityFaction"+id[i]]
		
		var operator = [1,-1]
		new_node.faction_changes[i].faction_id = current_json["OptionFactions"+String(i+1)]
		new_node.faction_changes[i].points = current_json["OptionFaction"+String(i+1)+"Points"] * operator[current_json["DecreaseFaction"+String(i+1)+"Points"]]
	loaded_dialog_nodes.append(new_node)
	imported_dialogs.remove(index)
	for i in current_json["Options"]:
		var response = DialogEditor.add_response_node(new_node)
		response.slot = i["OptionSlot"]
		response.command = i["Option"]["DialogCommand"]
		response.to_dialog_id = i["Option"]["Dialog"]
		response.response_title = i["Option"]["Title"]
		response.initial_color = String(int_to_color(int(i["Option"]["DialogColor"])))
		response.option_type = response.get_option_id(i["Option"]["OptionType"])
	return new_node				

func create_dialogs_from_responses(dialog):
	for response in dialog.response_options:
		
		if response.to_dialog_id != -1:
			var dialog_already_loaded = false
			for loaded_dialog in loaded_dialog_nodes:
				if loaded_dialog.dialog_id == response.to_dialog_id:
					dialog_already_loaded = loaded_dialog
			if !dialog_already_loaded:
				for json_dialog in imported_dialogs:
					if json_dialog["DialogId"] == response.to_dialog_id:
						var connected_dialog = create_dialog_from_json_array(imported_dialogs.find(json_dialog),response.offset+Vector2(320,-40)-DialogEditor.scroll_offset)
						DialogEditor.connect_nodes(response.get_name(),0,connected_dialog.get_name(),0)
						create_dialogs_from_responses(connected_dialog)
			else:
				DialogEditor.connect_nodes(response.get_name(),0,dialog_already_loaded.get_name(),0)
				



func int_to_color(integer):
	var r = (integer >> 16) & 0xff
	var g = (integer >> 8) & 0xff
	var b = integer & 0xff
	return Color(r,g,b,1)


func _on_CategoryPanel_import_category_request(category_name):
	import_category(category_name)
