extends Control

enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

var sgn = load("res://Scenes/Nodes/DialogNode.tscn")
var initial_position = Vector2(300,300)
var node_index = 0
var selected_nodes = []
var node_deletion_queue = []

onready var hide_npc_checkbox = $SidePanel/DialogNodeTabs/DialogSettings/DialogSettings/VBoxContainer/HideNPC
onready var show_wheel_checkbox = $SidePanel/DialogNodeTabs/DialogSettings/DialogSettings/VBoxContainer/ShowDialogWheel
onready var disable_esc_checkbox = $SidePanel/DialogNodeTabs/DialogSettings/DialogSettings/VBoxContainer/DisableEsc
onready var title_label = $SidePanel/DialogNodeTabs/DialogSettings/DialogSettings/VBoxContainer/Title
func _ready():
	OS.low_processor_usage_mode = true
	$GraphEdit.get_zoom_hbox().visible = false
	
	$GraphEdit.add_valid_connection_type(CONNECTION_TYPES.PORT_FROM_RESPONSE,CONNECTION_TYPES.PORT_INTO_DIALOG)
	$GraphEdit.add_valid_connection_type(CONNECTION_TYPES.PORT_INTO_RESPONSE,CONNECTION_TYPES.PORT_FROM_DIALOG)
	
	$GraphEdit.remove_valid_connection_type(CONNECTION_TYPES.PORT_FROM_DIALOG,CONNECTION_TYPES.PORT_INTO_RESPONSE)
	$GraphEdit.add_valid_left_disconnect_type(CONNECTION_TYPES.PORT_INTO_DIALOG)
	$GraphEdit.add_valid_right_disconnect_type(CONNECTION_TYPES.PORT_FROM_RESPONSE)

func _process(delta):
	if Input.is_action_pressed("ui_delete") and selected_nodes.size() > 0:
		for i in selected_nodes:
			print(selected_nodes)
			i.delete_self()
			selected_nodes.erase(i)
		


func add_dialog_node(offset_base=initial_position,new_name = "New Dialog"):
	var node = sgn.instance()
	node.offset += offset_base + $GraphEdit.scroll_offset
	node.title += ' - '+str(node_index)
	node.node_index = node_index
	node.graph = $GraphEdit
	node.dialog_title = new_name
	$GraphEdit.add_child(node)
	node_index += 1
	return node


func delete_dialog(dialog):
	if selected_nodes.find(dialog,0) != -1:
		selected_nodes.erase(dialog)
	check_selected_nodes()
	dialog.queue_free()
	node_index -=1

func delete_player_response(dialog,response):
	$GraphEdit.disconnect_node(dialog.get_name(),0,response.get_name(),0)
	if response.connected_dialog != null:
		$GraphEdit.disconnect_node(response.get_name(),0,response.connected_dialog.get_name(),0)
		response.connected_dialog.connected_responses.erase(response)
		response.connected_dialog = null
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

func _on_GraphEdit_node_unselected(node):
	if node.node_type == "Dialog Node":
		selected_nodes.erase(node)
		if selected_nodes.size() < 1:
			$SidePanel/DialogNodeTabs.visible = false
		else:
			load_dialog_settings(selected_nodes[0])
			
	
func _on_GraphEdit_node_selected(node):
	if selected_nodes.find(node,0) == -1 and node.node_type == "Dialog Node" :
		selected_nodes.append(node)
		$SidePanel/DialogNodeTabs.visible = true
		load_dialog_settings(node)
		
func check_selected_nodes():
	if selected_nodes.size() < 1:
		$SidePanel/DialogNodeTabs.visible = false
	else:
		if selected_nodes[0].node_type == "Dialog Node":
			load_dialog_settings(selected_nodes[0])
		
func load_dialog_settings(dialog):
	title_label.text = dialog.dialog_title+" | Node "+String(dialog.node_index)
	hide_npc_checkbox.pressed = dialog.hide_npc
	show_wheel_checkbox.pressed = dialog.show_wheel
	disable_esc_checkbox.pressed = dialog.disable_esc
	
	$SidePanel/DialogNodeTabs/DialogSettings/DialogSettings/VBoxContainer/Command.text = dialog.command
	$SidePanel/DialogNodeTabs/DialogSettings/DialogSettings/VBoxContainer/Soundfile.text = dialog.sound

#Dialog Changes

func _on_HideNPC_pressed():
	selected_nodes[0].hide_npc = hide_npc_checkbox.pressed


func _on_ShowDialogWheel_pressed():
	selected_nodes[0].show_wheel = show_wheel_checkbox.pressed


func _on_DisableEsc_pressed():
	selected_nodes[0].disable_esc = disable_esc_checkbox.pressed

func _on_node_requests_selection(node):
	$GraphEdit.set_selected(node)
	_on_GraphEdit_node_selected(node)
	print("selected node")
