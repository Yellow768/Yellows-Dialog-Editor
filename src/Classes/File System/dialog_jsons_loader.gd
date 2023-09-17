class_name dialog_jsons_loader
extends Node

func get_dialog_jsons(category_name : String) -> Array:
	return return_valid_dialog_jsons(category_name)

func return_valid_dialog_jsons(category_name : String) -> Array[Dictionary]:
	var current_category_directory : String = CurrentEnvironment.current_directory+"/dialogs/"+category_name
	var parsed_jsons : Array[Dictionary]= []
	var dir_search := DirectorySearch.new()
	var files = dir_search.scan_all_subdirectories(current_category_directory,["json"])
	if files.size() == 0 :
		return parsed_jsons
	else:
		var current_dialog
		for file in files:
			current_dialog = FileAccess.open(current_category_directory+"/"+file,FileAccess.READ)
			var JSON_parse = JSON.new()
			JSON_parse.parse(replace_unparseable_dialog_json_values(current_dialog))
			var dialog_json_with_bad_values_replaced : Dictionary = JSON_parse.get_data()
			if JSON_parse.get_error_line() != OK || !is_json_valid_dialog_format(dialog_json_with_bad_values_replaced):
				printerr("Error parsing JSON "+file+", skipping. ERR = "+str(JSON_parse.get_error_line())+" valid_dialog_format = "+str(is_json_valid_dialog_format(dialog_json_with_bad_values_replaced)))
			else:
				parsed_jsons.append(dialog_json_with_bad_values_replaced)		
		parsed_jsons.sort_custom(Callable(self, "sort_array_by_dialog_title"))
	return parsed_jsons

func replace_unparseable_dialog_json_values(json_file : FileAccess) -> String:
	var final_result = json_file.get_as_text()
	while(json_file.get_position() < json_file.get_length()):
		var current_line := json_file.get_line()
		if '"DialogShowWheel": ' in current_line or '"DialogHideNPC"' in current_line or '"DecreaseFaction1Points"' in current_line or '"DecreaseFaction2Points"' in current_line or '"BeenRead"' in current_line or '"DialogDisableEsc"' in current_line:
			var replace_line := current_line
			replace_line = current_line.replace("0b","0")
			replace_line = replace_line.replace("1b","1")
			final_result = final_result.replace(current_line,replace_line)
		if '"TimePast"' in current_line or '"Time' in current_line:
			var replace_line := current_line
			replace_line = current_line.replace("L","")
			final_result = final_result.replace(current_line,replace_line)
	return final_result

func is_file_valid_dialog_json(json_file : JSON) -> bool:
	if json_file.error == OK && is_json_valid_dialog_format(json_file.result):
		return true	
	else:
		return false

func is_json_valid_dialog_format(dialog_json : Dictionary) -> bool:
	if !dialog_json.has("DialogTitle") or typeof(dialog_json["DialogTitle"]) != TYPE_STRING:
		printerr("DialogTitle is malformed")
		return false
	if !dialog_json.has("DialogId") or typeof(dialog_json["DialogId"]) != TYPE_FLOAT:
		printerr("DialogId is malformed")
		return false
	if !dialog_json.has("DialogText") or typeof(dialog_json["DialogText"]) != TYPE_STRING:
		printerr("DialogText is malformed")
		return false
	if !dialog_json.has("DialogQuest") or typeof(dialog_json["DialogQuest"]) != TYPE_FLOAT:
		printerr("DialogQuest is malformed")
		return false
	if !dialog_json.has("DialogDisableEsc") or typeof(dialog_json["DialogDisableEsc"]) != TYPE_FLOAT:
		printerr("DialogDisableEsc is malformed")
		return false
	if !dialog_json.has("DialogShowWheel") or typeof(dialog_json["DialogShowWheel"]) != TYPE_FLOAT:
		printerr("DialogShowWheel is malformed")
		return false
	if !dialog_json.has("AvailabilityMinPlayerLevel") or typeof(dialog_json["AvailabilityMinPlayerLevel"]) != TYPE_FLOAT:
		printerr("DialogLevelAvailability is malformed")
		return false
	if !dialog_json.has("AvailabilityDayTime") or typeof(dialog_json["AvailabilityDayTime"]) != TYPE_FLOAT:
		printerr("DialogDaytimeAvail is malformed")
		return false

	var id := ["","2","3","4"]
	for i in 4:
		if !dialog_json.has("AvailabilityQuest"+id[i]+"Id") or typeof(dialog_json["AvailabilityQuest"+id[i]+"Id"]) != TYPE_FLOAT:
			printerr("AvailabilityQuest"+id[i]+"Id"+" is malformed")
			return false
		if !dialog_json.has("AvailabilityQuest"+id[i]) or typeof(dialog_json["AvailabilityQuest"+id[i]]) != TYPE_FLOAT:
			printerr("AvailabilityQuest"+id[i]+" is malformed")
			return false
		if !dialog_json.has("AvailabilityDialog"+id[i]+"Id") or typeof(dialog_json["AvailabilityDialog"+id[i]+"Id"]) != TYPE_FLOAT:
			printerr("AvailabilityDialog"+id[i]+"Id"+" is malformed")
			return false
		if !dialog_json.has("AvailabilityDialog"+id[i]) or typeof(dialog_json["AvailabilityDialog"+id[i]]) != TYPE_FLOAT:
			printerr("AvailabilityDialog"+id[i]+" is malformed")
			return false
	for i in 2:
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Objective") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Objective"]) != TYPE_STRING:
			printerr("AvailabilityScoreboard"+id[i]+"Objective is malformed")
			return false
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Value") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Value"]) != TYPE_FLOAT:
			printerr("AvailabilityScoreboard"+id[i]+"Value is malformed")
			return false
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Type") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Type"]) != TYPE_FLOAT:
			printerr("AvailabilityScoreboard"+id[i]+"Type is malformed")
			return false
		
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Id") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Id"]) != TYPE_FLOAT:
			printerr("AvailabilityFaction"+id[i]+"Id is malformed")
			return false
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Stance") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Stance"]) != TYPE_FLOAT:
			printerr("AvailabilityFaction"+id[i]+"Stance is malformed")
			return false
		if !dialog_json.has("AvailabilityFaction"+id[i]) or typeof(dialog_json["AvailabilityFaction"+id[i]]) != TYPE_FLOAT:
			printerr("AvailabilityFaction"+id[i]+" is malformed")
			return false

		if !dialog_json.has("OptionFactions"+str(i+1)) or typeof(dialog_json["OptionFactions"+str(i+1)]) != TYPE_FLOAT:
			printerr("OptionFactions"+str(i+1)+" is malformed")
			return false
		if !dialog_json.has("OptionFaction"+str(i+1)+"Points") or typeof(dialog_json["OptionFaction"+str(i+1)+"Points"]) != TYPE_FLOAT:
			printerr("OptionFactions"+str(i+1)+"Points is malformed")
			return false
		if !dialog_json.has("DecreaseFaction"+str(i+1)+"Points") or typeof(dialog_json["DecreaseFaction"+str(i+1)+"Points"]) != TYPE_FLOAT:
			printerr("DecreaseFactions"+str(i+1)+"Points is malformed")
			return false
		
		if !dialog_json.has("Options") or typeof(dialog_json["Options"]) != TYPE_ARRAY:
			printerr("Options is malformed")
			return false
	
	var response_options_are_valid := true
	for i in dialog_json["Options"]:
		if !i.has("OptionSlot") or typeof(i["OptionSlot"]) != TYPE_FLOAT:
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
		if !i["Option"].has("DialogColor") or typeof(i["Option"]["DialogColor"]) != TYPE_FLOAT:
			printerr("A Response Color is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("OptionType") or typeof(i["Option"]["OptionType"]) != TYPE_FLOAT:
			printerr("A Response OptionType is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("Dialog") or typeof(i["Option"]["Dialog"]) != TYPE_FLOAT:
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
