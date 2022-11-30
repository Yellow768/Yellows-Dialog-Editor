tool
extends GraphNode

signal set_self_as_selected
signal delete_self
signal connect_to_dialog_request
signal disconnect_from_dialog_request




var node_type = "Player Response Node"
var graph
var initial_color = "Color(1,1,1,1)"

var slot = -1


var response_title = ''
var color_decimal = 16777215 setget set_color_decimal
var command = '' setget set_command
var connected_dialog = null setget set_connected_dialog
var initial_y_offset = 0 setget set_initial_y_offset
var to_dialog_id = -1 setget set_to_dialog_id
var option_type = 0

var parent_dialog
var permanent_offset

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
	set_slot(0,true,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,Color(0,1,0,1),true,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,Color(0,0,1,1))
	set_initial_color(initial_color)
	response_text_node.text = response_title
	option_type_node.selected = option_type


func delete_self():
	if(connected_dialog != null):
		connected_dialog.remove_connected_response(self)
	emit_signal("delete_self",slot,self)
	
func disconnect_from_dialog():
	emit_signal("disconnect_from_dialog_request",self.name,0,connected_dialog.name,0)
	connected_dialog = null
	reveal_button()
	
func reveal_button():
	new_dialog_button_node.visible = true

	
func hide_button():
	new_dialog_button_node.visible = false
	
	
func set_response_title(new_title):
	response_text_node.text = new_title

func set_option_type(new_type):
	option_type_node.select(new_type)
	if new_type == 2:
		command_text_node.visible = true
	else:
		command_text_node.visible = false
	if new_type == 0:
		reveal_button()
		set_slot_enabled_right(0,true)
	
	else:
		hide_button()
		set_slot_enabled_right(0,false)
		if connected_dialog != null:
			emit_signal("disconnect_from_dialog_request",self.name,0,connected_dialog.name,0)
			connected_dialog.remove_connected_response(self)
			connected_dialog = null

func set_initial_color(new_color):
	color_picker_node.color = str2var(new_color)

func set_color_decimal(new_color):
	color_decimal = new_color
func set_command(new_command):
	command_text_node.text = new_command

func set_connected_dialog(new_connected_dialog):
	connected_dialog = new_connected_dialog
	if connected_dialog != null:
		hide_button()

func set_initial_y_offset(new_offset):
	initial_y_offset = new_offset

func set_to_dialog_id(new_id):
	to_dialog_id = new_id


func _on_PlayerResponseNode_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		selected = true
		emit_signal("set_self_as_selected",self)
		self.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		self.mouse_filter = Control.MOUSE_FILTER_PASS


func _on_PlayerResponseNode_close_request():
	delete_self()
	

func _on_AddNewDialog_pressed():
	var new_name = "New Dialog"
	if response_text_node.text != '':
		new_name = response_text_node.text
	var node = graph.add_dialog_node((offset+Vector2(320,-40))-graph.scroll_offset,new_name)
	connected_dialog = node
	connected_dialog.connected_responses.append(self)
	emit_signal("connect_to_dialog_request",self.name,0,connected_dialog.name,0)
	hide_button()


func _on_OptionButton_item_selected(index):
	option_type = index
	set_option_type(index)


func _on_ColorPickerButton_color_changed(color):
	initial_color = var2str(color)
	var colorHex = "0x"+String(color.to_html(false))
	color_decimal = colorHex.hex_to_int()






func _on_PlayerResponseNode_dragged(from, _to):
	if main_environment.selected_responses.size() > 0:
		if main_environment.selected_nodes.find(parent_dialog) == -1:
			offset = from
		else:
			permanent_offset = offset




func _on_ResponseText_text_changed():
	response_title = response_text_node.text


func _on_CommandText_text_changed():
	command = command_text_node.text
