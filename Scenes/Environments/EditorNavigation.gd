extends Panel

onready var file_button = $TopPanelContainer/File


func _ready():
	var file_popup = file_button.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")

func save():
	
	var save_category = File.new()
	save_category.open("user://category_test.dec",File.WRITE)
	
	var save_nodes = get_tree().get_nodes_in_group("Save")
	
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

func load_category():
	var save_category = File.new()
	var loaded_dialogs = []
	var loaded_responses = []
	if not save_category.file_exists("user://category_test.dec"):
		return
	
	var save_nodes = get_tree().get_nodes_in_group("Save")
	$"..".node_index = 0
	$"..".selected_responses = []
	$"..".selected_nodes = []
	loaded_dialogs.resize(500)
	for i in save_nodes:
		i.queue_free()
		
	save_category.open("user://category_test.dec",File.READ)
	while(save_category.get_position() < save_category.get_len()):
		var node_data = parse_json(save_category.get_line())
		var new_object = load(node_data["filename"]).instance()
		
		new_object.offset = Vector2(node_data["offset.x"],node_data["offset.y"])
		
		for i in node_data.keys():
			if i == "offset.x" or i == "offset.y" or i == "filename" or i == "quest_availabilities" or i == "dialog_availabilities" or i == "faction_availabilities" or i == "scoreboard_availabilities" or i == "faction_changes" or i == "response_options":
				continue
			new_object.set(i, node_data[i])
		var loaded_dialog = $"..".add_dialog_node(new_object.offset,new_object.dialog_title,new_object.node_index)
		loaded_dialogs.insert(new_object.node_index,loaded_dialog)
		
		for i in node_data.response_options:
			var loaded_response = $"..".add_response_node(loaded_dialog, i.response_title)
			loaded_response.slot = i.slot
			loaded_response.color_decimal = i.color_decimal
			loaded_response.command = i.command
			loaded_response.to_dialog_id = i.connected_dialog_index
			loaded_response.initial_color = i.initial_color
			loaded_response.response_title = i.response_title
			loaded_responses.append(loaded_response)
	save_category.close()
	for i in loaded_responses:
		if i.to_dialog_id != null:
			print(loaded_dialogs.find(i.to_dialog_id))
			$"..".connect_nodes(i.name,0,loaded_dialogs[i.to_dialog_id].name,0)
	

func file_menu(id):
	match id:
		2:
			save()
		10:
			load_category()

