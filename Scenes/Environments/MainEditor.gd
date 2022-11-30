extends Control

var current_directory

var dialog_node_scene = load("res://Scenes/Nodes/DialogNode.tscn")
var response_node_scene = load("res://Scenes/Nodes/ResponseNode.tscn")

var initial_position = Vector2(300,300)
var node_index = 0
var selected_nodes = []
var selected_responses = []

export(NodePath) var _dialog_environment_path



onready var dialog_graph = get_node(_dialog_environment_path)
onready var information_panel = $InformationPanel
onready var dialog_settings_panel = $InformationPanel/DialogNodeTabs


func _ready():
	OS.low_processor_usage_mode = true
	dialog_graph.get_zoom_hbox().visible = false
	
	dialog_graph.add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	dialog_graph.add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG)
	
	dialog_graph.remove_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE)
	dialog_graph.add_valid_left_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	dialog_graph.add_valid_right_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE)
	
	scan_cnpc_directory()


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


func _process(_delta):
	if Input.is_action_pressed("ui_delete"):
		for i in selected_nodes:
			i.delete_self()
			selected_nodes.erase(i)
		for i in selected_responses:
			i.delete_self()
			selected_responses.erase(i)

func add_dialog_node(offset_base : Vector2 = initial_position, new_name : String = "New Dialog",new_index = -1):
	var new_node = dialog_node_scene.instance()
	
	new_node.offset += offset_base + dialog_graph.scroll_offset
	new_node.dialog_title = new_name
	node_index += 1
	if new_index != -1:
		new_node.node_index = new_index
	else:
		new_node.node_index = node_index
	new_node.title += ' - '+str(node_index)
		
	new_node.connect("add_response_request",self,"add_response_node")
	new_node.connect("delete_response_node",self,"delete_response_node")
	new_node.connect("dialog_ready_for_deletion",self,"delete_dialog_node")
	new_node.connect("set_self_as_selected",self,"_on_node_requests_selection")
	dialog_graph.add_child(new_node)
	return new_node


func delete_dialog_node(dialog):
	if selected_nodes.find(dialog,0) != -1:
		selected_nodes.erase(dialog)
	check_selected_nodes()
	dialog.queue_free()
	node_index -=1


func add_response_node(dialog):
	var new_node = response_node_scene.instance()
	var new_instance_offset = Vector2(350,35+(60*dialog.response_options.size()))
	for i in dialog.response_options:
		i.offset -= Vector2(0,60)
	dialog.response_options.append(new_node)
	
	new_node.offset = dialog.offset + new_instance_offset
	new_node.initial_y_offset = new_instance_offset.y
	new_node.slot = dialog.response_options.size()
	new_node.graph = dialog_graph
	new_node.main_environment_path = $"."
	new_node.parent_dialog = dialog
	new_node.permanent_offset = new_node.offset
	new_node.connect("delete_self",dialog,"delete_response_node")
	new_node.connect("connect_to_dialog_request", self, "connect_nodes")
	new_node.connect("disconnect_from_dialog_request",self,"disconnect_nodes")
	#new_node.connect("set_self_as_selected",self,"_on_node_requests_selection")
	dialog_graph.add_child(new_node)
	dialog_graph.connect_node(dialog.get_name(),0,new_node.get_name(),0)
	
	return new_node

func delete_response_node(dialog,response):
	dialog_graph.disconnect_node(dialog.get_name(),0,response.get_name(),0)
	if response.connected_dialog != null:
		dialog_graph.disconnect_node(response.get_name(),0,response.connected_dialog.get_name(),0)
		response.connected_dialog.remove_connected_response(response)
		response.connected_dialog = null
	if selected_responses.find(response) != -1:
		selected_responses.erase(response)
	response.queue_free()


func connect_nodes(from, from_slot, to, to_slot):
	var response
	var dialog
	
	if dialog_graph.get_node(from).node_type == "Player Response Node":
		response = dialog_graph.get_node(from)
		dialog = dialog_graph.get_node(to)
	else:
		response = dialog_graph.get_node(to)
		dialog = dialog_graph.get_node(from)
	
	
	if response.connected_dialog != null:
		dialog_graph.disconnect_node(response.get_name(),from_slot,response.connected_dialog.get_name(),to_slot)
	response.connected_dialog = dialog
	dialog_graph.connect_node(from,from_slot,to,to_slot)
	dialog.add_connected_response(response)

	
func disconnect_nodes(from, from_slot, to, to_slot):
	var response
	var dialog
	
	if dialog_graph.get_node(from).node_type == "Player Response Node":
		response = dialog_graph.get_node(from)
		dialog = dialog_graph.get_node(to)
	else:
		response = dialog_graph.get_node(to)
		dialog = dialog_graph.get_node(from)
	
	if response.connected_dialog == dialog:
		dialog_graph.disconnect_node(from,from_slot,to,to_slot)
		dialog.remove_connected_response(response)
		response.reveal_button()
		response.connected_dialog = null
		
		
	else:
		dialog_graph.disconnect_node(from,from_slot,to,to_slot)
		response.reveal_button()
		

func _on_BTN_AddNode_pressed():
	add_dialog_node()


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	connect_nodes(from, from_slot, to, to_slot)



func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	disconnect_nodes(from, from_slot, to, to_slot)


func _on_GraphEdit_node_selected(node):
	if node.node_type == "Player Response Node":
		selected_responses.append(node)
	if selected_nodes.find(node,0) == -1 and node.node_type == "Dialog Node" :
		selected_nodes.append(node)
		dialog_settings_panel.load_dialog_settings(node)

func _on_GraphEdit_node_unselected(node):
	if node.node_type == "Player Response Node":
		selected_responses.erase(node)
	if node.node_type == "Dialog Node":
		selected_nodes.erase(node)
		if selected_nodes.size() < 1:
			information_panel.visible = false
		else:
			dialog_settings_panel.load_dialog_settings(selected_nodes[0])
		
func check_selected_nodes():
	if selected_nodes.size() < 1:
		information_panel.visible = false
	else:
		if selected_nodes[0].node_type == "Dialog Node":
			dialog_settings_panel.load_dialog_settings(selected_nodes[0])

		
func _on_node_requests_selection(node):
	selected_nodes = []
	selected_responses = []
	dialog_graph.set_selected(node)
	_on_GraphEdit_node_selected(node)
