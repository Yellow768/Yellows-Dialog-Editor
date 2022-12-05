extends Node

signal clear_editor_request
signal update_current_category


var imported_dialogs = []

export(NodePath) var _dialog_editor_path
export(NodePath) var _main_program_path
export(NodePath) var _environment_index_path

onready var EnvironmentIndex = get_node(_environment_index_path)
onready var DialogEditor = get_node(_dialog_editor_path)
onready var MainProgram = get_node(_main_program_path)
var response_node = load("res://Scenes/Nodes/ResponseNode.tscn")


func read_file():
	var array_of_shit = ["test",'test2','"Time": '+String(56)]
	var read_category = File.new()
	var write_category = File.new()
	read_category.open("user://96.json",File.READ)
	write_category.open("user://test.json",File.WRITE)
	while(read_category.get_position() < read_category.get_len()):
		var cool_thing = read_category.get_line()
		array_of_shit.append(cool_thing)
		
	read_category.close()
	
	for i in array_of_shit:
		write_category.store_line(i)
	write_category.close()


			
func save_category(category_name):
	if CurrentEnvironment.current_directory != null && CurrentEnvironment.current_category_name != null :
		var save_category = File.new()
		var save_nodes = get_tree().get_nodes_in_group("Save")
		save_category.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec",File.WRITE)
		for node in save_nodes:
			if node.filename.empty():
				print("Node '%s' is not instanced, skipped" % node.name)
				continue
			
			if !node.has_method("save"):
				print("Node '%s' is missing a save() function, skipped" % node.name)
				continue
			
			var category_data = node.call("save")
			
			save_category.store_line(to_json(category_data))
		save_category.close()
		if !EnvironmentIndex.get_category_has_ydec(category_name):
			EnvironmentIndex.add_ydec_to_indexed_category(category_name)
	else:
		print("Nothing To Save")

func load_category(category_name):
	save_category(CurrentEnvironment.current_category_name)
	CurrentEnvironment.loading_stage = true
	emit_signal("clear_editor_request")
	var current_category_path = CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec"
	var save_category = File.new()
	if not save_category.file_exists(current_category_path):
		print("Not a valid path")
	else:
		
		var loaded_dialogs = []
		var loaded_responses = []	
		save_category.open(current_category_path,File.READ)
		while(save_category.get_position() < save_category.get_len()):
			var node_data = parse_json(save_category.get_line())
			var new_object = load(node_data["filename"]).instance()
			
			var currently_loaded_dialog = DialogEditor.add_dialog_node(Vector2(node_data["offset.x"],node_data["offset.y"]),new_object.dialog_title,new_object.node_index)

			
			for i in node_data.keys():
				if i == "offset.x" or i == "offset.y" or i == "filename" or i == "quest_availabilities" or i == "dialog_availabilities" or i == "faction_availabilities" or i == "scoreboard_availabilities" or i == "faction_changes" or i == "response_options":
					continue
				currently_loaded_dialog.set(i, node_data[i])
			
			currently_loaded_dialog.time_availability = node_data["time_availability"]
			currently_loaded_dialog.min_level_availability = node_data["min_level_availability"]
			
			for i in 4:
				currently_loaded_dialog.quest_availabilities[i].set_id(node_data["quest_availabilities"][i].quest_id)
				currently_loaded_dialog.quest_availabilities[i].set_availability(node_data["quest_availabilities"][i].availability_type)
				currently_loaded_dialog.dialog_availabilities[i].set_id(node_data["dialog_availabilities"][i].dialog_id)
				currently_loaded_dialog.dialog_availabilities[i].set_availability(node_data["dialog_availabilities"][i].availability_type)
				
			for i in 2:
				currently_loaded_dialog.faction_availabilities[i].set_id(node_data["faction_availabilities"][i].faction_id)
				currently_loaded_dialog.faction_availabilities[i].set_stance(node_data["faction_availabilities"][i].stance_type)
				currently_loaded_dialog.faction_availabilities[i].set_operator(node_data["faction_availabilities"][i].availability_operator)
				
				currently_loaded_dialog.faction_changes[i].set_id(node_data["faction_changes"][i].faction_id)
				currently_loaded_dialog.faction_changes[i].set_points(node_data["faction_changes"][i].points)
				
				currently_loaded_dialog.scoreboard_availabilities[i].set_name(node_data["scoreboard_availabilities"][i].objective_name)
				currently_loaded_dialog.scoreboard_availabilities[i].set_comparison_type(node_data["scoreboard_availabilities"][i].comparison_type)
				currently_loaded_dialog.scoreboard_availabilities[i].set_value(node_data["scoreboard_availabilities"][i].value)
			
			loaded_dialogs.append(currently_loaded_dialog)
			
			for i in node_data["response_options"]:
				var currently_loaded_response = DialogEditor.add_response_node(currently_loaded_dialog)
				
				currently_loaded_response.slot = i.slot
				currently_loaded_response.color_decimal = i.color_decimal
				currently_loaded_response.to_dialog_id = i.to_dialog_id
				currently_loaded_response.command = i.command
				currently_loaded_response.option_type = i.option_type
				currently_loaded_response.response_title = i.response_title
				currently_loaded_response.initial_color = i.initial_color
				
				loaded_responses.append(currently_loaded_response)
		
		for i in loaded_responses:
			var connected_dialog
			for dialog in loaded_dialogs:
				if dialog.dialog_id == i.to_dialog_id:
					connected_dialog = dialog
			if i.to_dialog_id > 0:
				DialogEditor.connect_nodes(i.name,0,connected_dialog.name,0)
		save_category.close()
		emit_signal("update_current_category",category_name)
	CurrentEnvironment.loading_stage = false



func _on_CategoryPanel_load_existing_category_request(category_name):
	load_category(category_name)


func _on_CategoryImporter_save_category_request(category_name):
	save_category(category_name)


func _on_TopPanel_save_category_request():
	save_category(CurrentEnvironment.current_category_name)


