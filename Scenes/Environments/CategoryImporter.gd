extends Node

signal save_category_request
signal clear_editor_request
signal set_current_category_path
signal category_has_ydec
signal update_current_category


export(NodePath) var _main_program_path
export(NodePath) var _dialog_list_vbox_path
export(NodePath) var _dialog_editor_path


var current_category_directory
var imported_dialogs = []
var imported_category_name

onready var MainProgram = get_node(_main_program_path)
onready var DialogButtonList = get_node(_dialog_list_vbox_path)
onready var DialogEditor = get_node(_dialog_editor_path)


func import_category(category_name):
	if(CurrentEnvironment.current_category_name != null):
		emit_signal("save_category_request",CurrentEnvironment.current_category_name)
	imported_dialogs = []
	imported_dialogs = import_dialog_jsons(category_name)
	create_initial_dialog_tree_buttons(imported_dialogs)
	imported_category_name = category_name



func import_dialog_jsons(category_name : String) -> Array:
	var parsed_jsons = []
	current_category_directory = CurrentEnvironment.current_directory+"/dialogs/"+category_name
	var dir_search = DirectorySearch.new()
	var files = dir_search.scan_all_subdirectories(current_category_directory,["json"])
	if files.size() == 0 :
		return parsed_jsons
	else:
		var current_dialog = File.new()
		for file in files:
			current_dialog.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+file,File.READ)
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
				if validate_dialog_json(json_result):
					parsed_jsons.append(json_result)
			else:
				printerr("Invalid Dialog JSON "+file+", skipping")
		parsed_jsons.sort_custom(self,"sort_array_by_dialog_title")
	return parsed_jsons

func validate_dialog_json(dialog_json):
	if !dialog_json.has("DialogTitle") or typeof(dialog_json["DialogTitle"]) != TYPE_STRING:
		printerr("DialogTitle is malformed")
		return false
	if !dialog_json.has("DialogId") or typeof(dialog_json["DialogId"]) != TYPE_REAL:
		printerr("DialogId is malformed")
		return false
	if !dialog_json.has("DialogText") or typeof(dialog_json["DialogText"]) != TYPE_STRING:
		printerr("DialogText is malformed")
		return false
	if !dialog_json.has("DialogQuest") or typeof(dialog_json["DialogQuest"]) != TYPE_REAL:
		printerr("DialogQuest is malformed")
		return false
	if !dialog_json.has("DialogDisableEsc") or typeof(dialog_json["DialogDisableEsc"]) != TYPE_REAL:
		printerr("DialogDisableEsc is malformed")
		return false
	if !dialog_json.has("DialogShowWheel") or typeof(dialog_json["DialogShowWheel"]) != TYPE_REAL:
		printerr("DialogShowWheel is malformed")
		return false
	if !dialog_json.has("AvailabilityMinPlayerLevel") or typeof(dialog_json["AvailabilityMinPlayerLevel"]) != TYPE_REAL:
		printerr("DialogLevelAvailability is malformed")
		return false
	if !dialog_json.has("AvailabilityDayTime") or typeof(dialog_json["AvailabilityDayTime"]) != TYPE_REAL:
		printerr("DialogDaytimeAvail is malformed")
		return false

	var id = ["","2","3","4"]
	for i in 4:
		if !dialog_json.has("AvailabilityQuest"+id[i]+"Id") or typeof(dialog_json["AvailabilityQuest"+id[i]+"Id"]) != TYPE_REAL:
			printerr("AvailabilityQuest"+id[i]+"Id"+" is malformed")
			return false
		if !dialog_json.has("AvailabilityQuest"+id[i]) or typeof(dialog_json["AvailabilityQuest"+id[i]]) != TYPE_REAL:
			printerr("AvailabilityQuest"+id[i]+" is malformed")
			return false
		if !dialog_json.has("AvailabilityDialog"+id[i]+"Id") or typeof(dialog_json["AvailabilityDialog"+id[i]+"Id"]) != TYPE_REAL:
			printerr("AvailabilityDialog"+id[i]+"Id"+" is malformed")
			return false
		if !dialog_json.has("AvailabilityDialog"+id[i]) or typeof(dialog_json["AvailabilityDialog"+id[i]]) != TYPE_REAL:
			printerr("AvailabilityDialog"+id[i]+" is malformed")
			return false
	for i in 2:
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Objective") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Objective"]) != TYPE_STRING:
			printerr("AvailabilityScoreboard"+id[i]+"Objective is malformed")
			return false
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Value") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Value"]) != TYPE_REAL:
			printerr("AvailabilityScoreboard"+id[i]+"Value is malformed")
			return false
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Type") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Type"]) != TYPE_REAL:
			printerr("AvailabilityScoreboard"+id[i]+"Type is malformed")
			return false
		
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Id") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Id"]) != TYPE_REAL:
			printerr("AvailabilityFaction"+id[i]+"Id is malformed")
			return false
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Stance") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Stance"]) != TYPE_REAL:
			printerr("AvailabilityFaction"+id[i]+"Stance is malformed")
			return false
		if !dialog_json.has("AvailabilityFaction"+id[i]) or typeof(dialog_json["AvailabilityFaction"+id[i]]) != TYPE_REAL:
			printerr("AvailabilityFaction"+id[i]+" is malformed")
			return false

		if !dialog_json.has("OptionFactions"+String(i+1)) or typeof(dialog_json["OptionFactions"+String(i+1)]) != TYPE_REAL:
			printerr("OptionFactions"+String(i+1)+" is malformed")
			return false
		if !dialog_json.has("OptionFaction"+String(i+1)+"Points") or typeof(dialog_json["OptionFaction"+String(i+1)+"Points"]) != TYPE_REAL:
			printerr("OptionFactions"+String(i+1)+"Points is malformed")
			return false
		if !dialog_json.has("DecreaseFaction"+String(i+1)+"Points") or typeof(dialog_json["DecreaseFaction"+String(i+1)+"Points"]) != TYPE_REAL:
			printerr("DecreaseFactions"+String(i+1)+"Points is malformed")
			return false
		
		if !dialog_json.has("Options") or typeof(dialog_json["Options"]) != TYPE_ARRAY:
			printerr("Options is malformed")
			return false
	
	var response_options_are_valid = true
	for i in dialog_json["Options"]:
		if !i.has("OptionSlot") or typeof(i["OptionSlot"]) != TYPE_REAL:
			printerr("A Response OptionSlot is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("DialogCommand") or typeof(i["Option"]["DialogCommand"]) != TYPE_STRING:
			printerr("A Response DialogCommand is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("Title") or typeof(i["Option"]["Title"]) != TYPE_STRING:
			printerr("A Response Title is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("DialogColor") or typeof(i["Option"]["DialogColor"]) != TYPE_REAL:
			printerr("A Response Color is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("OptionType") or typeof(i["Option"]["OptionType"]) != TYPE_REAL:
			printerr("A Response OptionType is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("Dialog") or typeof(i["Option"]["Dialog"]) != TYPE_REAL:
			printerr("A Response Dialog is malformed")
			response_options_are_valid = false
			return false
	
	if response_options_are_valid:
		return true
	else:
		return false



func sort_array_by_dialog_title(a,b):
	if a["DialogTitle"] != b["DialogTitle"]:
		return a["DialogTitle"] < b["DialogTitle"]
	else:
		return a["DialogTitle"]  < b["DialogTitle"] 

	
func create_initial_dialog_tree_buttons(all_dialogs):
	for button in $PopupPanel/ScrollContainer/VBoxContainer.get_children():
		button.queue_free()
	for i in all_dialogs.size():
		var dialog_button = Button.new()
		dialog_button.text = all_dialogs[i]["DialogTitle"]
		dialog_button.connect("pressed",self,"create_tree_from_inital_dialog",[dialog_button])
		DialogButtonList.add_child(dialog_button)	
	$PopupPanel.visible = true
	


var loaded_dialog_nodes = []
var loaded_responses = []

func create_tree_from_inital_dialog(button_chosen):
	emit_signal("clear_editor_request")
	CurrentEnvironment.loading_stage = true
	loaded_dialog_nodes = []
	loaded_responses = []
	var index = DialogButtonList.get_children().find(button_chosen)
	var initial_dialog = create_dialog_from_json_array(index,Vector2(300,300))
	create_dialogs_from_responses(initial_dialog)
	var count = 0
	for unimported_dialog in imported_dialogs:
		count+= 1
		var unconnected_dialog = create_dialog_from_json_array(imported_dialogs.find(unimported_dialog),Vector2(300*count,900+(300*count)))
		create_dialogs_from_responses(unconnected_dialog)
	for i in loaded_responses:
		i.currently_importing = false
		i.check_dialog_distance()
		i.update_connection_text()
	emit_signal("update_current_category",imported_category_name)
	CurrentEnvironment.loading_stage = false
	
	$PopupPanel.visible = false
	for button in $PopupPanel/ScrollContainer/VBoxContainer.get_children():
		button.queue_free()
	CurrentEnvironment.current_category_name = imported_category_name
	emit_signal("save_category_request",imported_category_name)
	


func create_dialog_from_json_array(index,offset):
	
	var new_node = DialogEditor.add_dialog_node(offset)
	var current_json = imported_dialogs[index]
	new_node.dialog_title = current_json["DialogTitle"]
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
	
	for i in current_json["Options"]:
		var response = DialogEditor.add_response_node(new_node)
		response.slot = i["OptionSlot"]
		response.command = i["Option"]["DialogCommand"]
		response.to_dialog_id = i["Option"]["Dialog"]
		response.response_title = i["Option"]["Title"]
		response.color_decimal = i["Option"]["DialogColor"]
		response.initial_color = "Color("+String(int_to_color(int(i["Option"]["DialogColor"])))+")"
		response.option_type = response.get_option_id(i["Option"]["OptionType"])
		response.currently_importing = true
	loaded_dialog_nodes.append([new_node,current_json["DialogId"]])
	imported_dialogs.remove(index)
	return new_node				

func create_dialogs_from_responses(dialog):
	for response in dialog.response_options:
		
		if response.to_dialog_id != -1:
			var dialog_already_loaded = false
			for loaded_dialog in loaded_dialog_nodes:
				if loaded_dialog[1] == response.to_dialog_id:
					dialog_already_loaded = loaded_dialog[0]
					
			
			if !dialog_already_loaded:
				for json_dialog in imported_dialogs:
					if json_dialog["DialogId"] == response.to_dialog_id:
						var connected_dialog = create_dialog_from_json_array(imported_dialogs.find(json_dialog),response.offset+Vector2(320,0)-DialogEditor.scroll_offset)
						DialogEditor.connect_nodes(response.get_name(),0,connected_dialog.get_name(),0)
						create_dialogs_from_responses(connected_dialog)
			
			else:
				
				DialogEditor.connect_nodes(response.get_name(),0,dialog_already_loaded.get_name(),0)
			loaded_responses.append(response)

				



func int_to_color(integer):
	var r = (integer >> 16) & 0xff
	var g = (integer >> 8) & 0xff
	var b = integer & 0xff
	var color = Color(1,1,1)
	color.r8 = r
	color.g8 = g
	color.b8 = b
	return color


func _on_CategoryPanel_import_category_request(category_name):
	import_category(category_name)



func _on_CancelButton_pressed():
	$PopupPanel.visible = false
