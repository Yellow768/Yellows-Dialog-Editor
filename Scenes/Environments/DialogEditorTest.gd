extends Control



var dialog_node_scene = load("res://Scenes/Nodes/DialogNode.tscn")
var response_node_scene = load("res://Scenes/Nodes/Player Response Node.tscn")

var initial_position = Vector2(300,300)
var node_index = 0
var selected_nodes = []
var selected_responses = []

onready var dialog_settings_panel = $SidePanel/DialogNodeTabs





func _ready():
	OS.low_processor_usage_mode = true
	$GraphEdit.get_zoom_hbox().visible = false
	
	$GraphEdit.add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	$GraphEdit.add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG)
	
	$GraphEdit.remove_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE)
	$GraphEdit.add_valid_left_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	$GraphEdit.add_valid_right_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE)

func _process(delta):
	if Input.is_action_pressed("ui_delete"):
		for i in selected_nodes:
			print(selected_nodes)
			i.delete_self()
			selected_nodes.erase(i)
		for i in selected_responses:
			i.delete_self()
			selected_responses.erase(i)

func add_dialog_node(offset_base : Vector2 = initial_position, new_name : String = "New Dialog"):
	var new_node = dialog_node_scene.instance()
	new_node.offset += offset_base + $GraphEdit.scroll_offset
	new_node.title += ' - '+str(node_index)
	new_node.node_index = node_index
	new_node.graph = $GraphEdit
	new_node.dialog_title = new_name
	node_index += 1
	$GraphEdit.add_child(new_node)
	return new_node


func delete_dialog_node(dialog):
	if selected_nodes.find(dialog,0) != -1:
		selected_nodes.erase(dialog)
	check_selected_nodes()
	dialog.queue_free()
	node_index -=1


func add_response_node(dialog):
	var new_node = response_node_scene.instance()
	var new_instance_offset = Vector2(350,40+(60*dialog.response_options.size()))
	for i in dialog.response_options:
		i.offset -= Vector2(0,60)
	dialog.response_options.append(new_node)
	
	new_node.offset = dialog.offset + new_instance_offset
	new_node.initial_y_offset = new_instance_offset.y
	new_node.slot = dialog.response_options.size()
	new_node.graph = $GraphEdit
	new_node.connect("delete_self",dialog,"delete_response_node")
	#new_node.connect("set_self_as_selected",self,"_on_node_requests_selection")
	$GraphEdit.add_child(new_node)
	$GraphEdit.connect_node(dialog.get_name(),0,new_node.get_name(),0)


func delete_response_node(dialog,response):
	$GraphEdit.disconnect_node(dialog.get_name(),0,response.get_name(),0)
	if response.connected_dialog != null:
		$GraphEdit.disconnect_node(response.get_name(),0,response.connected_dialog.get_name(),0)
		response.connected_dialog.connected_responses.erase(response)
		response.connected_dialog = null
	if selected_responses.find(response) != -1:
		selected_responses.erase(response)
	response.queue_free()





func _on_BTN_AddNode_pressed():
	add_dialog_node()


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	var response_node
	
	if $GraphEdit.get_node(from).node_type == "Player Response Node":
		response_node = $GraphEdit.get_node(from)
	else:
		response_node = $GraphEdit.get_node(to)
	
	
	if response_node.connected_dialog == null:
		response_node.connected_dialog = $GraphEdit.get_node(to)
	else:
		$GraphEdit.disconnect_node(response_node.get_name(),from_slot,response_node.connected_dialog.get_name(),to_slot)
		response_node.connected_dialog = $GraphEdit.get_node(to)
	
	$GraphEdit.connect_node(from,from_slot,to,to_slot)
	response_node.hide_button()
	response_node.connected_dialog.connected_responses.append(response_node)



func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	var response_node
	var dialog
	if $GraphEdit.get_node(from).node_type == "Player Response Node":
		response_node = $GraphEdit.get_node(from)
		dialog = $GraphEdit.get_node(to)
	else:
		response_node = $GraphEdit.get_node(to)
		dialog = $GraphEdit.get_node(from)
	
	if response_node.connected_dialog == dialog:
		$GraphEdit.disconnect_node(from,from_slot,to,to_slot)
		response_node.reveal_button()
		dialog.connected_responses.erase(response_node)
		response_node.connected_dialog = null
	else:
		$GraphEdit.disconnect_node(from,from_slot,to,to_slot)



func _on_GraphEdit_node_selected(node):
	if node.node_type == "Player Response Node":
		selected_responses.append(node)
		print(selected_responses)
	if selected_nodes.find(node,0) == -1 and node.node_type == "Dialog Node" :
		selected_nodes.append(node)
		dialog_settings_panel.load_dialog_settings(node)

func _on_GraphEdit_node_unselected(node):
	if node.node_type == "Player Response Node":
		selected_responses.erase(node)
		print(selected_responses)
	if node.node_type == "Dialog Node":
		selected_nodes.erase(node)
		if selected_nodes.size() < 1:
			dialog_settings_panel.visible = false
		else:
			dialog_settings_panel.load_dialog_settings(selected_nodes[0])
		
func check_selected_nodes():
	if selected_nodes.size() < 1:
		dialog_settings_panel.visible = false
	else:
		if selected_nodes[0].node_type == "Dialog Node":
			dialog_settings_panel.load_dialog_settings(selected_nodes[0])

		
func _on_node_requests_selection(node):
	selected_nodes = []
	selected_responses = []
	$GraphEdit.set_selected(node)
	_on_GraphEdit_node_selected(node)






################################Saving##########################################



