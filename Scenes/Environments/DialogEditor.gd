extends GraphEdit

const RESPONSE_NODE_VERTICAL_OFFSET = 100

signal no_dialog_selected
signal dialog_selected
signal editor_cleared


var dialog_node_scene = load("res://Scenes/Nodes/DialogNode.tscn")
var response_node_scene = load("res://Scenes/Nodes/ResponseNode.tscn")

var node_index = 0
var selected_nodes = []
var selected_responses = []
var previous_zoom = 1


func _ready():
	get_zoom_hbox().visible = false
	add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG)
	
	remove_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE)
	add_valid_left_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	add_valid_right_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE)
	set_process_input(false)

func _process(_delta):
	if Input.is_action_pressed("ui_delete"):
		handle_subtracting_dialog_id(selected_nodes)
		for i in selected_nodes:
			i.delete_self()
			selected_nodes.erase(i)
		for i in selected_responses:
			i.delete_self()
			selected_responses.erase(i)
	
func sort_array_by_dialog_id(a,b):
	if a.dialog_id != b.dialog_id:
		return a.dialog_id > b.dialog_id
	else:
		return a.dialog_id > b.dialog_id

func add_dialog_node(offset_base : Vector2 = OS.window_size/2, new_name : String = "New Dialog",new_index : int = -1, use_exact_offset : bool = false):
	var new_node = dialog_node_scene.instance()
	node_index += 1
	if new_index != -1:
		new_node.node_index = new_index
	else:
		new_node.node_index = node_index
	if !CurrentEnvironment.loading_stage:
		new_node.dialog_id = CurrentEnvironment.highest_id+1
		CurrentEnvironment.highest_id += 1
	if !use_exact_offset:
		new_node.offset = (offset_base+scroll_offset)/zoom
	else:
		new_node.offset = offset_base
	new_node.dialog_title = new_name
	new_node.title += ' - '+str(node_index)
	
		
	new_node.connect("add_response_request",self,"add_response_node")
	new_node.connect("delete_response_node",self,"delete_response_node")
	new_node.connect("dialog_ready_for_deletion",self,"delete_dialog_node")
	new_node.connect("set_self_as_selected",self,"_on_node_requests_selection")
	add_child(new_node)
	return new_node


func delete_dialog_node(dialog):
	if selected_nodes.find(dialog,0) != -1:
		selected_nodes.erase(dialog)
	set_last_selected_node_as_selected()
	dialog.queue_free()
	node_index -=1

func add_response_node(dialog):
	var new_node = response_node_scene.instance()
	var new_instance_offset = Vector2(350,0+(RESPONSE_NODE_VERTICAL_OFFSET*dialog.response_options.size()))
	for i in dialog.response_options:
		i.offset -= Vector2(0,RESPONSE_NODE_VERTICAL_OFFSET)
	dialog.response_options.append(new_node)
	new_node.offset = dialog.offset + new_instance_offset
	new_node.initial_y_offset = new_instance_offset.y
	new_node.slot = dialog.response_options.size()-1
	new_node.graph = self
	new_node.main_environment_path = $"."
	new_node.parent_dialog = dialog
	new_node.permanent_offset = new_node.offset
	new_node.connect("delete_self",dialog,"delete_response_node")
	new_node.connect("connect_to_dialog_request", self, "connect_nodes")
	new_node.connect("disconnect_from_dialog_request",self,"disconnect_nodes")
	add_child(new_node)
	connect_node(dialog.get_name(),0,new_node.get_name(),0)
	new_node.set_focus_on_title()
	return new_node

func delete_response_node(dialog,response):
	disconnect_node(dialog.get_name(),0,response.get_name(),0)
	if response.connected_dialog != null:
		disconnect_node(response.get_name(),0,response.connected_dialog.get_name(),0)
		response.connected_dialog.remove_connected_response(response)
		response.connected_dialog = null
	if selected_responses.find(response) != -1:
		selected_responses.erase(response)
	response.queue_free()


func connect_nodes(from, from_slot, to, to_slot):
	var response
	var dialog
	if get_node(from).node_type == "Player Response Node":
		response = get_node(from)
		dialog = get_node(to)
	else:
		response = get_node(to)
		dialog = get_node(from)
	
	
	if response.connected_dialog != null:
		disconnect_node(response.get_name(),from_slot,response.connected_dialog.get_name(),to_slot)
	response.connected_dialog = dialog
	if(response.offset.distance_to(dialog.offset) < 1000):
		connect_node(from,from_slot,to,to_slot)
	dialog.add_connected_response(response)


	
func disconnect_nodes(from, from_slot, to, to_slot):
	var response
	var dialog
	
	if get_node(from).node_type == "Player Response Node":
		response = get_node(from)
		dialog = get_node(to)
	else:
		response = get_node(to)
		dialog = get_node(from)
	
	if response.connected_dialog == dialog:
		response.set_connection_shown()
		disconnect_node(from,from_slot,to,to_slot)
		dialog.remove_connected_response(response)
		response.reveal_button()
		
		response.connected_dialog = null
		
		
	else:
		disconnect_node(from,from_slot,to,to_slot)
		response.reveal_button()

func hide_connection_line(from,to):
	disconnect_node(from,0,to,0)


func show_connection_line(from,to):
	connect_node(from,0,to,0)
	
func set_last_selected_node_as_selected():
	if selected_nodes.size() < 1:
		emit_signal("no_dialog_selected")
	else:
		if selected_nodes.back().node_type == "Dialog Node":
			emit_signal("dialog_selected",selected_nodes.back())

func handle_subtracting_dialog_id(dialogs_to_be_deleted : Array):
	var sorted_ids = dialogs_to_be_deleted.duplicate()
	sorted_ids.sort_custom(self,"sort_array_by_dialog_id")
	for node in sorted_ids:
		print(node.dialog_id)
		if node.dialog_id == CurrentEnvironment.highest_id:
			CurrentEnvironment.highest_id -= 1

func clear_editor():
	selected_responses = []
	selected_nodes = []
	var save_nodes = get_tree().get_nodes_in_group("Save")
	var response_nodes = get_tree().get_nodes_in_group("Response_Nodes")
	for i in save_nodes:
		i.delete_self()
	for i in response_nodes:
		i.delete_self()	
	node_index = 0
	emit_signal("editor_cleared")
	

func _on_BTN_AddNode_pressed():
	add_dialog_node()


func _on_DialogEditor_connection_request(from, from_slot, to, to_slot):
	connect_nodes(from, from_slot, to, to_slot)



func _on_DialogEditor_disconnection_request(from, from_slot, to, to_slot):
	disconnect_nodes(from, from_slot, to, to_slot)


func _on_DialogEditor_node_selected(node):
	if node.node_type == "Player Response Node":
		selected_responses.append(node)
	if selected_nodes.find(node,0) == -1 and node.node_type == "Dialog Node" :
		selected_nodes.append(node)
		emit_signal("dialog_selected",node)

func _on_DialogEditor_node_unselected(node):
	if node.node_type == "Player Response Node":
		selected_responses.erase(node)
	if node.node_type == "Dialog Node":
		selected_nodes.erase(node)
		set_last_selected_node_as_selected()
		


		
func _on_node_requests_selection(node):
	selected_nodes = []
	selected_responses = []
	set_selected(node)
	_on_DialogEditor_node_selected(node)


func _on_CategoryImporter_clear_editor_request():
	clear_editor()


func _on_SaveLoad_clear_editor_request():
	clear_editor()



func _on_DialogEditor_gui_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_WHEEL_UP:
		if !Input.is_action_pressed("shift"):
			accept_event()
		else:
			zoom += .02
	if event is InputEventMouseButton && event.button_index == BUTTON_WHEEL_DOWN:
		if !Input.is_action_pressed("shift"):
			accept_event()
		else:
			zoom -= .02
