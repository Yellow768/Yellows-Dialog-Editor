tool
extends GraphNode

signal set_self_as_selected
signal delete_self
signal connect_to_dialog_request
signal disconnect_from_dialog_request




var node_type = "Player Response Node"
var graph
var initial_color = "Color(1,1,1,1)" setget set_initial_color

var slot = -1 setget set_response_slot


var response_title = '' setget set_response_title
var color_decimal = 16777215 setget set_color_decimal
var command = '' setget set_command
var connected_dialog = null setget set_connected_dialog
var initial_y_offset = 0 setget set_initial_y_offset
var to_dialog_id = -1 setget set_to_dialog_id
var option_type = 0 setget set_option_type

var parent_dialog
var permanent_offset


var connection_hidden = false
var overlapping_response = null

export(NodePath) var _response_text_node_path
export(NodePath) var _color_picker_node_path
export(NodePath) var _option_type_node_path
export(NodePath) var _command_text_node_path
export(NodePath) var _new_dialog_button_path
export(NodePath) var main_environment_path

onready var response_text_node = get_node(_response_text_node_path)
onready var color_picker_node = get_node(_color_picker_node_path)
onready var option_type_node = get_node(_option_type_node_path)
onready var command_text_node = get_node(_command_text_node_path)
onready var new_dialog_button_node = get_node(_new_dialog_button_path)
onready var main_environment = get_parent().get_parent()



func _ready():
	set_slot(0,true,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.response_left_slot_color,true,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.response_right_slot_color)
	set_initial_color(initial_color)
	response_text_node.text = response_title
	check_dialog_distance()
	update_connection_text()

func get_option_id(option_int):
	return $HBoxContainer/VBoxContainer/OptionTypeButton.get_item_index(option_int)


func set_response_slot(value):
	slot = value
	title = "Response Option "+String(value+1) 


func set_focus_on_title():
	response_text_node.grab_focus()

	
func set_response_title(new_title):
	response_title = new_title
	$HBoxContainer/VBoxContainer/ResponseText.text = new_title

func set_option_type(new_type):
	option_type = new_type
	$HBoxContainer/VBoxContainer/OptionTypeButton.selected = new_type
	if new_type == 2:
		$HBoxContainer/VBoxContainer/CommandText.visible = true
	else:
		$HBoxContainer/VBoxContainer/CommandText.visible = false
	if new_type == 0:
		reveal_button()
		set_slot_enabled_right(0,true)
	
	else:
		hide_button()
		set_slot_enabled_right(0,false)
		if connected_dialog != null:
			emit_signal("disconnect_from_dialog_request",self.name,0,connected_dialog.name,0)


func set_initial_color(new_color):
	initial_color = new_color
	$HBoxContainer/VBoxContainer/ColorPickerButton.color = str2var(new_color)
	

func set_color_decimal(new_color):
	color_decimal = new_color

func set_command(new_command):
	command = new_command
	$HBoxContainer/VBoxContainer/CommandText.text = new_command

func set_connected_dialog(new_connected_dialog):
	connected_dialog = new_connected_dialog
	if connected_dialog != null:
		hide_button()
		update_connection_text()
		check_dialog_distance()
		to_dialog_id = connected_dialog.dialog_id

func set_initial_y_offset(new_offset):
	initial_y_offset = new_offset

func set_to_dialog_id(new_id):
	to_dialog_id = new_id

	
func reveal_button():
	new_dialog_button_node.visible = true

	
func hide_button():
	new_dialog_button_node.visible = false
	

func set_connection_text(dialog_name,dialog_node_index):
	$VBOXRemoteConnection/ConnectedLabel.text = "Connected to "+dialog_name+" | Node "+String(dialog_node_index)

func update_connection_text():
	if connected_dialog != null:
		var format_string = "Connected to %s | Node "+String(connected_dialog.node_index)
		$VBOXRemoteConnection/ConnectedLabel.text = format_string % connected_dialog.dialog_title.left(10)

func check_dialog_distance():
	if connected_dialog != null:
		if offset.distance_to(connected_dialog.offset) > 1000 && !connection_hidden:
			set_connection_hidden()	
		if offset.distance_to(connected_dialog.offset) < 1000 && connection_hidden:
			set_connection_shown()

func set_connection_hidden():
	graph.hide_connection_line(self.name,connected_dialog.name)
	connection_hidden = true
	$VBOXRemoteConnection.visible = true
	set_slot_color_right(0,GlobalDeclarations.response_right_slot_color_hidden)
	set_slot_enabled_right(0,false)
	connected_dialog.set_slot_color_left(0,GlobalDeclarations.dialog_left_slot_color_hidden)
	update_connection_text()

func set_connection_shown():
	graph.show_connection_line(self.name,connected_dialog.name)
	connection_hidden = false
	set_slot_color_right(0,GlobalDeclarations.response_right_slot_color)
	connected_dialog.set_slot_color_left(0,GlobalDeclarations.dialog_left_slot_color)
	set_slot_enabled_right(0,true)
	$VBOXRemoteConnection.visible = false


func disconnect_from_dialog():
	connected_dialog.remove_connected_response(self)
	emit_signal("disconnect_from_dialog_request",self.name,0,connected_dialog.name,0)
	$VBOXRemoteConnection.visible = false
	reveal_button()

func delete_self():
	if(connected_dialog != null):
		connected_dialog.remove_connected_response(self)
	emit_signal("delete_self",slot,self)
	




func _on_PlayerResponseNode_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		selected = true
		emit_signal("set_self_as_selected",self)


func _on_PlayerResponseNode_close_request():
	delete_self()
	

func _on_AddNewDialog_pressed():
	var new_name = "New Dialog"
	if response_text_node.text != '':
		new_name = response_text_node.text
	var offset_base = offset+Vector2(320,0)
	var node = graph.add_dialog_node(offset_base,new_name,-1,true)
	connected_dialog = node
	connected_dialog.connected_responses.append(self)
	emit_signal("connect_to_dialog_request",self.name,0,connected_dialog.name,0)
	hide_button()


func _on_OptionButton_item_selected(index):
	set_option_type(index)


func _on_ColorPickerButton_color_changed(color):
	initial_color = var2str(color)
	var colorHex = "0x"+String(color.to_html(false))
	color_decimal = colorHex.hex_to_int()






func _on_PlayerResponseNode_dragged(from, to):
	if graph.selected_responses.size() > 0:
		if graph.selected_nodes.size() == 0:
			handle_slot_changing(from,to)
		elif graph.selected_nodes.find(parent_dialog) == -1:
			offset = from
		else:
			permanent_offset = offset
			check_dialog_distance()

# warning-ignore:unused_argument
func handle_slot_changing(old_offset,new_offset):
	if overlapping_response != null:
		
		var initial_slot = slot
		var overlap_slot = overlapping_response.slot
		var initial_parent = parent_dialog
		var overlap_parent = overlapping_response.parent_dialog
		var initial_offset = old_offset
		var overlap_offset = overlapping_response.offset 
		
		#Switch Slots
		set_response_slot(overlap_slot)
		overlapping_response.slot = initial_slot
		
		#Switch positions
		offset = overlap_offset
		overlapping_response.offset = initial_offset
		
		#Remove from parents array
		parent_dialog.response_options.erase(self)
		graph.disconnect_node(parent_dialog.get_name(),0,self.name,0)
		disconnect("delete_self",parent_dialog,"delete_response_node")
		
		overlapping_response.parent_dialog.response_options.erase(overlapping_response)
		graph.disconnect_node(overlapping_response.parent_dialog.get_name(),0,overlapping_response.get_name(),0)
		overlapping_response.disconnect("delete_self",overlapping_response.parent_dialog,"delete_response_node")
		
		#Switch to other parents array. Make sure slot isn't invalid
		if parent_dialog.response_options.size() >= overlapping_response.slot:
			parent_dialog.response_options.insert(overlapping_response.slot,overlapping_response)
		else:
			parent_dialog.response_options.append(overlapping_response)
		graph.connect_node(parent_dialog.get_name(),0,overlapping_response.get_name(),0)
		
		if overlapping_response.parent_dialog.response_options.size() >= slot:
			overlapping_response.parent_dialog.response_options.insert(slot,self)
		else:
			overlapping_response.parent_dialog.response_options.append(self)
		graph.connect_node(overlapping_response.parent_dialog.get_name(),0,self.get_name(),0)
		
		#Switch Parents
		parent_dialog = overlap_parent
		overlapping_response.parent_dialog = initial_parent
		
		connect("delete_self",parent_dialog,"delete_response_node")
		overlapping_response.connect("delete_self",overlapping_response.parent_dialog,"delete_response_node")
	else:
		offset = old_offset
		
		


func _on_ResponseText_text_changed():
	response_title = response_text_node.text


func _on_CommandText_text_changed():
	command = command_text_node.text


func _on_DisconnectButton_pressed():
	disconnect_from_dialog()


func _on_JumpButton_pressed():
	graph.set_scroll_ofs((connected_dialog.offset * Vector2(graph.zoom,graph.zoom))-OS.window_size/2)
	connected_dialog.emit_signal("set_self_as_selected",connected_dialog)


func _on_ResponseNodeArea_area_entered(area):
	overlapping_response = area.get_parent()
	

func _on_ResponseNodeArea_area_exited(_area):
	if !$ResponseNodeArea.get_overlapping_areas().empty():
		print($ResponseNodeArea.get_overlapping_areas().back().get_parent())
		overlapping_response = $ResponseNodeArea.get_overlapping_areas().back().get_parent()
	else:
		overlapping_response = null
