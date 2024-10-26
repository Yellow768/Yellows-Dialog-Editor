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
			var dialog_json_with_bad_values_replaced = JSON_parse.get_data()
			if JSON_parse.get_error_line() != 0:
				printerr("Error parsing JSON "+file+", malformed. "+JSON_parse.get_error_message()+" at "+str(JSON_parse.get_error_line()),", Skipping Importing.")
				continue
			if(!dialog_json_with_bad_values_replaced):
				printerr(file+" is malformed. Skipping Importing.")
				continue
			if !is_json_valid_dialog_format(dialog_json_with_bad_values_replaced,file):
				printerr("JSON "+file+" is valid, but not in CNPC Dialog Format. Skipping Importing")
				continue 
			else:
				parsed_jsons.append(dialog_json_with_bad_values_replaced)		
		parsed_jsons.sort_custom(Callable(self, "sort_array_by_dialog_title"))
	return parsed_jsons


#The JSON files that CustomNPC creates use some format that marks booleans as 1b or 0b,
#and long ints as 12345L. Godot's JSON parser doesn't account for these values, and so
#errors out and doesn't properly import the dictionary. This function first imports the file as text,
#and then replaces those unparseable values so that Godot can read it

func replace_unparseable_dialog_json_values(json_file : FileAccess) -> String:
	var final_result = json_file.get_as_text()
	var regex := RegEx.new()
	var first_mail_item_brack_position = final_result.find("[",final_result.find('"MailIItems": ['))
	if first_mail_item_brack_position == -1:
		first_mail_item_brack_position = final_result.find("[",final_result.find('"MailItems": ['))
	var last_mail_item_brack = final_result.rfind("]")
	var mail_items_as_string : String = final_result.substr(first_mail_item_brack_position+1,(last_mail_item_brack-first_mail_item_brack_position)-1)
	final_result = final_result.replace(mail_items_as_string,replace_unparsable_data_in_mail_items(mail_items_as_string))
	regex.compile("(\\w+(?: \\w+)*):") # Some really old dialogs don't have quotes around JSON keys. This adds them so that Godot can properly load it
	while(json_file.get_position() < json_file.get_length()):
		var current_line := json_file.get_line()
		if !'"DialogSound"' in current_line and !'"Line"' in current_line and !'"DialogCommand"' in current_line and !"TextSound" in current_line and !"Texture" in current_line and !"id" in current_line:
			#Sounds and Commands might use the name space, minecraft: , which the above regex would change to "minecraft":, which would mess up the json
			#final_result = final_result.replace(current_line,regex.sub(current_line,'"$1": ',false))
			#current_line = regex.sub(current_line,'"$1": ',false)
			pass
		var replace_line := current_line
		
		if '"DialogShowWheel": ' in current_line or '"DialogHideNPC"' in current_line or '"DecreaseFaction1Points"' in current_line or '"DecreaseFaction2Points"' in current_line or '"Decrease":' in current_line or '"DialogStopMusic"' in current_line or '"BeenRead"' in current_line or '"DialogDisableEsc"' in current_line or "DialogAlignment" in current_line or "RenderGradual" in current_line or "ShowOptionLine" in current_line or "DialogDarkScreen" in current_line or "PreviousBlocks" in current_line:
			
			replace_line = current_line.replace("0b","0")
			replace_line = replace_line.replace("1b","1")
			
			final_result = final_result.replace(current_line,replace_line)
			
		if '"TimePast"' in current_line or '"Time' in current_line:
			replace_line = current_line.replace("L","")
			final_result =final_result.replace(current_line,replace_line)
		if "Alpha" in current_line or "Scale" in current_line or "TextPitch" in current_line or "NPCScale" in current_line or "Rotation" in current_line:
			replace_line = current_line.replace("f","")
			final_result = final_result.replace(current_line,replace_line)

	return final_result

func replace_unparsable_data_in_mail_items(mail_items : String):
	var regex = RegEx.new()
	regex.compile('(?<=\\d)[a-zA-Z]+')
	var mail_dictionary = regex.sub(mail_items,'',true)
	return mail_dictionary
	

func is_json_valid_dialog_format(dialog_json : Dictionary,file : String) -> bool:
	if !dialog_json.has("DialogTitle") or typeof(dialog_json["DialogTitle"]) != TYPE_STRING:
		printerr("DialogTitle is malformed")
		dialog_json.merge({"DialogTitle" : "Error When Importing"})
	if !dialog_json.has("DialogId") or typeof(dialog_json["DialogId"]) != TYPE_FLOAT:
		if file.get_file().replace(".json","").is_valid_int():
			dialog_json.merge({"DialogId" : int(file.get_file().replace(".json",""))})
			push_warning("DialogId is malformed or missing, substituting with file name in json ",file)
		else:
			dialog_json.merge({"DialogId" : -1})
			push_warning("DialogId is malformed or missing, file name is not a vlid number, setting ID to -1 in json ",file)
	if !dialog_json.has("DialogText") or typeof(dialog_json["DialogText"]) != TYPE_STRING:
		printerr("DialogText is malformed")
		dialog_json.merge({"DialogText" : "Error When Importing"})
	if !dialog_json.has("DialogQuest") or typeof(dialog_json["DialogQuest"]) != TYPE_FLOAT:
		printerr("DialogQuest is malformed in json ",file)
		dialog_json.merge({"DialogQuest" : -1})
	if !dialog_json.has("DialogDisableEsc") or typeof(dialog_json["DialogDisableEsc"]) != TYPE_FLOAT:
		printerr("DialogDisableEsc is malformed in json ",file)
		dialog_json.merge({"DialogDisableEsc" : false})
	if !dialog_json.has("DialogShowWheel") or typeof(dialog_json["DialogShowWheel"]) != TYPE_FLOAT:
		printerr("DialogShowWheel is malformed in json ",file)
		dialog_json.merge({"DialogShowWheel" : false})
	if !dialog_json.has("AvailabilityMinPlayerLevel") or typeof(dialog_json["AvailabilityMinPlayerLevel"]) != TYPE_FLOAT:
		printerr("DialogLevelAvailability is malformed in json,file")
		dialog_json.merge({"AvailabilityMinPlayerLevel" : -1})
	if !dialog_json.has("AvailabilityDayTime") or typeof(dialog_json["AvailabilityDayTime"]) != TYPE_FLOAT:
		printerr("DialogDaytimeAvail is malformed in json ",file)
		dialog_json.merge({"AvailabilityDayTime" : -1})
	if !dialog_json.has("DialogCommands") or typeof(dialog_json["DialogCommands"]) != TYPE_ARRAY:
		dialog_json.merge({"DialogCommands" : []})
	if !dialog_json.has("DialogMail") or typeof(dialog_json["DialogMail"]) != TYPE_DICTIONARY:
		dialog_json.merge({"DialogMail" : {"Sender":"","Subject":"","Message":{},"MailItems":{},"MailQuest":-1}})
	if !dialog_json["DialogMail"].has("Sender") or typeof(dialog_json["DialogMail"]["Sender"]) != TYPE_STRING:
		dialog_json["DialogMail"]["Sender"] = ""
	if !dialog_json["DialogMail"].has("Message") or typeof(dialog_json["DialogMail"]["Message"]) != TYPE_DICTIONARY:
		dialog_json["DialogMail"]["Message"] = {}
	if !dialog_json["DialogMail"].has("MailItems") or typeof(dialog_json["DialogMail"]["MailItems"]) != TYPE_ARRAY:
		dialog_json["DialogMail"]["MailItems"] = []
	if !dialog_json["DialogMail"].has("MailQuest") or typeof(dialog_json["DialogMail"]["MailQuest"]) != TYPE_INT:
		dialog_json["DialogMail"]["MailQuest"] = -1
	if !dialog_json["DialogMail"].has("Subject") or typeof(dialog_json["DialogMail"]["Subject"]) != TYPE_STRING:
		dialog_json["DialogMail"]["Subject"] = ""
	var id := ["","2","3","4"]
	for i in 4:
		if !dialog_json.has("AvailabilityQuest"+id[i]+"Id") or typeof(dialog_json["AvailabilityQuest"+id[i]+"Id"]) != TYPE_FLOAT:
			printerr("AvailabilityQuest"+id[i]+"Id"+" is malformed in json ",file)
			dialog_json.merge({"AvailabilityQuest"+id[i]+"Id" : -1})
		if !dialog_json.has("AvailabilityQuest"+id[i]) or typeof(dialog_json["AvailabilityQuest"+id[i]]) != TYPE_FLOAT:
			printerr("AvailabilityQuest"+id[i]+" is malformed in json ",file)
			dialog_json.merge({"AvailabilityQuest"+id[i] : -1})
		if !dialog_json.has("AvailabilityDialog"+id[i]+"Id") or typeof(dialog_json["AvailabilityDialog"+id[i]+"Id"]) != TYPE_FLOAT:
			printerr("AvailabilityDialog"+id[i]+"Id"+" is malformed in json ",file)
			dialog_json.merge({"AvailabilityDialog"+id[i]+"Id" : -1})
		if !dialog_json.has("AvailabilityDialog"+id[i]) or typeof(dialog_json["AvailabilityDialog"+id[i]]) != TYPE_FLOAT:
			printerr("AvailabilityDialog"+id[i]+" is malformed in json ",file)
			dialog_json.merge({"AvailabilityDialog"+id[i] : -1})
	if !dialog_json.has("Points") or typeof(dialog_json["Points"]) != TYPE_ARRAY:
			dialog_json.merge({"Points" : []})
	for i in 2:
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Objective") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Objective"]) != TYPE_STRING:
			push_warning("AvailabilityScoreboard"+id[i]+"Objective is malformed or missing. Assuming pre 1.12 in json ",file)
			dialog_json.merge({"AvailabilityScoreboard"+id[i]+"Objective" : ""})
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Value") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Value"]) != TYPE_FLOAT:
			push_warning("AvailabilityScoreboard"+id[i]+"Value is malformed or missing. Assuming pre 1.12 in json ",file)
			dialog_json.merge({"AvailabilityScoreboard"+id[i]+"Value" : 0})
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Type") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Type"]) != TYPE_FLOAT:
			push_warning("AvailabilityScoreboard"+id[i]+"Type is malformed or missing. Assuming pre 1.12 in json ",file)
			dialog_json.merge({"AvailabilityScoreboard"+id[i]+"Type" : 0})
		
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Id") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Id"]) != TYPE_FLOAT:
			printerr("AvailabilityFaction"+id[i]+"Id is malformed in json ",file)
			dialog_json.merge({"AvailabilityFaction"+id[i]+"Id" : 0})
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Stance") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Stance"]) != TYPE_FLOAT:
			printerr("AvailabilityFaction"+id[i]+"Stance is malformed in json ",file)
			dialog_json.merge({"AvailabilityFaction"+id[i]+"Stance" : 0})
		if !dialog_json.has("AvailabilityFaction"+id[i]) or typeof(dialog_json["AvailabilityFaction"+id[i]]) != TYPE_FLOAT:
			printerr("AvailabilityFaction"+id[i]+" is malformed in json ",file)
			dialog_json.merge({"AvailabilityFaction"+id[i] : 0})
		if !dialog_json.has("OptionFactions"+str(i+1)) or typeof(dialog_json["OptionFactions"+str(i+1)]) != TYPE_FLOAT:
			push_warning("OptionFactions"+str(i+1)+" is missing. Possibly 1.18 file",file)
		if !dialog_json.has("OptionFaction"+str(i+1)+"Points") or typeof(dialog_json["OptionFaction"+str(i+1)+"Points"]) != TYPE_FLOAT:
			push_warning("OptionFactions"+str(i+1)+"Points is missing. Possibly 1.18 file ",file)
		if !dialog_json.has("DecreaseFaction"+str(i+1)+"Points") or typeof(dialog_json["DecreaseFaction"+str(i+1)+"Points"]) != TYPE_FLOAT:
			push_warning("DecreaseFactions"+str(i+1)+"Points is missing. Possibly 1.18 file ",file)
		
		if !dialog_json.has("Options") or typeof(dialog_json["Options"]) != TYPE_ARRAY:
			printerr("Options is malformed in json ",file)
			dialog_json.merge({"Options" : []})
		
	
	for i in dialog_json["Options"]:
		if !i.has("OptionSlot") or typeof(i["OptionSlot"]) != TYPE_FLOAT:
			printerr("A Response OptionSlot is malformed in json ",file)
			i.merge({"OptionSlot" : dialog_json["Options"].find(i)})
			
		if !i["Option"].has("DialogCommand") or typeof(i["Option"]["DialogCommand"]) != TYPE_STRING:
			printerr("A Response DialogCommand is missing in json. Possibly 1.18",file)
			i["Option"].merge({"DialogCommand" : ""})
		if !i["Option"].has("Commands") or typeof(i["Option"]["Commands"]) != TYPE_ARRAY:
			i["Option"].merge({"Commands" : []})
		if !i["Option"].has("Title") or typeof(i["Option"]["Title"]) != TYPE_STRING:
			printerr("A Response Title is malformed in json ",file)
			i["Option"].merge({"Title" : ""})
			
		if !i["Option"].has("DialogColor") or typeof(i["Option"]["DialogColor"]) != TYPE_FLOAT:
			printerr("A Response Color is malformed in json ",file)
			i["Option"].merge({"DialogColor" : 0xffffff})
			
		if !i["Option"].has("OptionType") or typeof(i["Option"]["OptionType"]) != TYPE_FLOAT:
			printerr("A Response OptionType is malformed in json ",file)
			i["Option"].merge({"OptionType" : 0})
			
		if !i["Option"].has("Dialog") or typeof(i["Option"]["Dialog"]) != TYPE_FLOAT:
			printerr("A Response Dialog is malformed in json ",file)
			i["Option"].merge({"Dialog" : -1})
		if !i["Option"].has("Text") or typeof(i["Option"]["Text"]) != TYPE_STRING:
			i["Option"].merge({"Text" : ""})
	return true




func sort_array_by_dialog_title(a,b):
	if a["DialogTitle"] != b["DialogTitle"]:
		return a["DialogTitle"] < b["DialogTitle"]
	else:
		return a["DialogTitle"]  < b["DialogTitle"] 
