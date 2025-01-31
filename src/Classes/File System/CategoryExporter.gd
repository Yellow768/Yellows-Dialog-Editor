class_name category_exporter
extends Node


func _ready():
	pass

func export_category(directory : String = CurrentEnvironment.current_directory+"/dialogs/",category_name : String = CurrentEnvironment.current_category_name,export_version:int = 2):
	var exported_category_dir := DirAccess.open(CurrentEnvironment.current_directory+"/dialogs")
	var save_nodes := get_tree().get_nodes_in_group("Save")
	
	
	if !exported_category_dir.dir_exists(directory+category_name):
		exported_category_dir.make_dir(directory+category_name)
	empty_category_jsons(category_name)
	for i in save_nodes:
		if i.node_type != "Dialog Node":
			continue
		var dialog_file := FileAccess.open(directory+category_name+"/"+str(i.dialog_id)+".json",FileAccess.WRITE)
		var new_dict = create_dialog_dict(i,export_version)
		#var jsonprint = JSON.print(new_dict,"\r\n")
		dialog_file.store_line(new_dict)
		dialog_file.close()
		
func empty_category_jsons(category_name : String):
	
	var dir := DirAccess.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
	#if dir.file_exists(CurrentEnvironment.current_directory+"/dialogs/highest_index.json"):
		#dir.remove(CurrentEnvironment.current_directory+"/dialogs/highest_index.json")
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name : String = dir.get_next()
		while file_name != "":
			if file_name == "autosave":
				dir.get_next()
			if dir.current_is_dir():
				empty_category_jsons(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+file_name)
			else:
				if file_name.get_extension() == "json":
					dir.remove(file_name)
			file_name = dir.get_next()
		


func create_dialog_dict(dialog : dialog_node, new_version):
	var dialog_dict = {
		"DialogShowWheel" : int(dialog.show_wheel),
		"DialogDisableEsc": int(dialog.disable_esc),
		"DialogHideNpc": int(dialog.hide_npc),
		"DialogText":dialog.text,
		"DialogTitle":dialog.dialog_title,
		"DialogSound":dialog.sound,
		"DialogStopMusic":int(dialog.stop_music),
		"DialogId" : dialog.dialog_id,
		"DialogQuest": dialog.start_quest,
		"AvailabilityMinPlayerLevel" : dialog.min_level_availability,
		"AvailabilityDayTime": dialog.time_availability,
		"ModRev":18,
		"Options": create_option_dict(dialog.response_options,new_version),
		"DialogHideNPC":int(dialog.hide_npc),
		"AvailabilityFactionStance" : dialog.faction_availabilities[0].stance_type,
		"AvailabilityFactionId" : dialog.faction_availabilities[0].faction_id,
		"AvailabilityFaction" : dialog.faction_availabilities[0].availability_operator,
		"AvailabilityFaction2Stance" : dialog.faction_availabilities[1].stance_type,
		"AvailabilityFaction2Id" : dialog.faction_availabilities[1].faction_id,
		"AvailabilityFaction2" : dialog.faction_availabilities[1].availability_operator,
		"AvailabilityScoreboardObjective" : dialog.scoreboard_availabilities[0].objective_name,
		"AvailabilityScoreboardType": dialog.scoreboard_availabilities[0].comparison_type,
		"AvailabilityScoreboardValue": dialog.scoreboard_availabilities[0].value,
		"AvailabilityScoreboard2Objective" : dialog.scoreboard_availabilities[1].objective_name,
		"AvailabilityScoreboard2Type": dialog.scoreboard_availabilities[1].comparison_type,
		"AvailabilityScoreboard2Value": dialog.scoreboard_availabilities[1].value,
		"AvailabilityQuestId":dialog.quest_availabilities[0].quest_id,
		"AvailabilityQuest": dialog.quest_availabilities[0].availability_type,
		"AvailabilityQuest2Id":dialog.quest_availabilities[1].quest_id,
		"AvailabilityQuest2": dialog.quest_availabilities[1].availability_type,
		"AvailabilityQuest3Id":dialog.quest_availabilities[2].quest_id,
		"AvailabilityQuest3": dialog.quest_availabilities[2].availability_type,
		"AvailabilityQuest4Id":dialog.quest_availabilities[3].quest_id,
		"AvailabilityQuest4": dialog.quest_availabilities[3].availability_type,
		"AvailabilityDialog": dialog.dialog_availabilities[0].availability_type,
		"AvailabilityDialogId": dialog.dialog_availabilities[0].dialog_id,
		"AvailabilityDialog2": dialog.dialog_availabilities[1].availability_type,
		"AvailabilityDialog2Id": dialog.dialog_availabilities[1].dialog_id,
		"AvailabilityDialog3": dialog.dialog_availabilities[2].availability_type,
		"AvailabilityDialog3Id": dialog.dialog_availabilities[2].dialog_id,
		"AvailabilityDialog4": dialog.dialog_availabilities[3].availability_type,
		"AvailabilityDialog4Id": dialog.dialog_availabilities[3].dialog_id,
		
		}
	if GlobalDeclarations.enable_customnpcs_plus_options:
		dialog_dict["DialogAlignment"] = int(dialog.alignment)
		dialog_dict["RenderGradual"] = int(dialog.render_gradual)
		dialog_dict["OptionOffsetX"] = dialog.option_offset_x
		dialog_dict["OptionOffsetY"] = dialog.option_offset_y
		dialog_dict["TextOffsetX"] = dialog.text_offset_x
		dialog_dict["TextOffsetY"] = dialog.text_offset_y
		dialog_dict["TitlePos"] = dialog.title_pos
		dialog_dict["TitleColor"] = dialog.title_color
		dialog_dict["ShowOptionLine"] = int(dialog.show_response_options)
		dialog_dict["Color"] = dialog.dialog_color
		dialog_dict["NPCScale"] = dialog.npc_scale
		dialog_dict["TextSound"] = dialog.text_sound
		dialog_dict["TextPitch"] = dialog.text_pitch
		dialog_dict["NPCOffsetX"] = dialog.npc_offset_x
		dialog_dict["NPCOffsetY"] = dialog.npc_offset_y
		dialog_dict["TextHeight"] = dialog.text_height
		dialog_dict["OptionSpaceX"] = dialog.option_spacing_x
		dialog_dict["OptionSpaceY"] = dialog.option_spacing_y
		dialog_dict["TitleOffsetX"] = dialog.title_offset_x
		dialog_dict["TitleOffsetY"] = dialog.title_offset_y
		dialog_dict["DialogDarkScreen"] = int(dialog.darken_screen)
		dialog_dict["TextWidth"] = dialog.text_width
		dialog_dict["PreviousBlocks"] = int(dialog.show_previous_dialog)
		dialog_dict["Images"] = create_image_dict(dialog)
	if !new_version:
		print("not new version")
		var fact1 = -1
		var fact1pts = 0
		var fact1decrease = 0
		var fact2 = -1
		var fact2pts = 0
		var fact2decrease = 0
		if dialog.faction_changes.size() >= 1:
			fact1 = dialog.faction_changes[0].faction_id
			fact1pts = abs(dialog.faction_changes[0].points)
			fact1decrease = dialog.faction_changes[0].operator
		if dialog.faction_changes.size() >= 2:
			fact2 = dialog.faction_changes[1].faction_id
			fact2pts = abs(dialog.faction_changes[1].points)
			fact2decrease = dialog.faction_changes[1].operator	
		dialog_dict.merge({
		"OptionFactions1": fact1,
		"OptionFaction1Points" : fact1pts,
		"DecreaseFaction1Points" : fact1decrease,
		"OptionFactions2": fact2,
		"OptionFaction2Points" : fact2pts,
		"DecreaseFaction2Points" : fact2decrease})
		if dialog.commands.size() > 0:
			dialog_dict["DialogCommand"] = dialog.commands[0]
		else:
			dialog_dict["DialogCommand"] = ""
	else:
		var points_array = []
		for faction_change in dialog.faction_changes:
			points_array.append({
				"Points" : abs(faction_change.points),
				"Decrease" : faction_change.operator,
				"Faction" : faction_change.faction_id
			})
		dialog_dict["Points"] = points_array
		var command_array = []
		for command in dialog.commands:
			command_array.append({
				"Line":command
			})
		dialog_dict["DialogCommands"] = command_array
			
		
	var dialog_dict_as_text = JSON.stringify(dialog_dict," ").replace("\\n","\n")
	dialog_dict_as_text = dialog_dict_as_text.left(-1)
	var mail_array_string = []
	if !new_version:
		mail_array_string = [",",
			'	"DialogMail": {',
				'		"Sender": "'+dialog.mail.sender.c_escape()+'",',
				'		"BeenRead": 0,',
				'		"Message": {',
						dialog.mail.compose_pages_string(),
				'		},',
				'		"MailItems": [',
						dialog.mail.compose_items_string(),
				'		],',
				'		"MailQuest": '+str(dialog.mail.quest_id)+',',
				'		"TimePast": 1669491043541L,',
				'		"Time": 0L,',
				'		"Subject": "'+dialog.mail.subject.c_escape()+'"',
				'	}',
			'}']
	else:
		mail_array_string = [",",
			'	"DialogMail": {',
				'		"Sender": "'+dialog.mail.sender.c_escape()+'",',
				'		"BeenRead": 0,',
				'		"Text": "'+dialog.mail.compose_pages_string(true)+'",',
				'		"MailIItems": [',
						dialog.mail.compose_items_string(),
				'		],',
				'		"MailQuest": '+str(dialog.mail.quest_id)+',',
				'		"TimePast": 1669491043541L,',
				'		"Time": 0L,',
				'		"Subject": "'+dialog.mail.subject.c_escape()+'"',
				'	}',
			'}']
	for line in mail_array_string:
		dialog_dict_as_text += "\n"+line
	return(dialog_dict_as_text)
	
func create_option_dict(responses,new_version):
	var response_array = []
	
	for response in responses:
		if !new_version:
			response_array.append({
				"OptionSlot":response.slot,
				"Option":{
					"DialogCommand":response.option_command,
					"Dialog":response.to_dialog_id,
					"Title":response.response_title,
					"DialogColor":response.color_decimal,
					"OptionType":response.get_option_id_from_index(response.option_type)
				}
			})
		else:
			var commands = []
			for command in response.commands:
				commands.append({
					"Line" : command
				})
			response_array.append({
				"OptionSlot":response.slot,
				"Option":{
					"Commands":commands,
					"Dialog":response.to_dialog_id,
					"Title":response.response_title,
					"Text": response.response_text,
					"DialogColor":response.color_decimal,
					"OptionType":response.get_option_id_from_index(response.option_type)
				}
			})
	return response_array

	
	

func create_image_dict(dialog):
	var images = []
	for image in dialog.image_dictionary:
		images.append({
			"PosX": dialog.image_dictionary[image].PosX,
			"PosY": dialog.image_dictionary[image].PosY,
			"Color":dialog.image_dictionary[image].Color,
			"TextureY": dialog.image_dictionary[image].TextureY,
			"TextureX": dialog.image_dictionary[image].TextureX,
			"Scale": snapped(dialog.image_dictionary[image].Scale,0.001),
			"SelectedColor": dialog.image_dictionary[image].SelectedColor,
			"Texture": dialog.image_dictionary[image].Texture.c_escape().replace("\\'","'"),
			"Rotation": snapped(dialog.image_dictionary[image].Rotation,0.01),
			"ImageType": dialog.image_dictionary[image].ImageType,
			"Alignment": dialog.image_dictionary[image].Alignment,
			"Alpha": snapped(dialog.image_dictionary[image].Alpha,0.01),
			"Height": dialog.image_dictionary[image].Height,
			"ID": image,
			"Width": dialog.image_dictionary[image].Width
		})
	return images	
