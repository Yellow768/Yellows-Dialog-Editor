tool
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

var node_type = "Player Response Node"
var graph


var slot = -1
export(int,"Close","Select Dialog","Disabled","Role","Command") var option_type = 1
var color_decimal = 16777215

var command = ''
var connected_dialog = null #might delete
var initial_y_offset = 0

var to_dialog_ID

signal deleting_player_response(slot)

func _ready():
	set_slot(0,true,CONNECTION_TYPES.PORT_INTO_RESPONSE,Color(0,1,0,1),true,CONNECTION_TYPES.PORT_FROM_RESPONSE,Color(0,0,1,1))


func external_delete():
	emit_signal("deleting_player_response",slot,self)

func _on_PlayerResponseNode_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		selected = true
		self.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		self.mouse_filter = Control.MOUSE_FILTER_PASS


func _on_PlayerResponseNode_close_request():
	if(connected_dialog != null):
		connected_dialog.connected_responses.erase(self)
	emit_signal("deleting_player_response",slot,self)
	

func disconnect_from_dialog():
	graph.disconnect_node(self.get_name(),0,connected_dialog.get_name(),0)
	connected_dialog.connected_responses.erase(self)
	connected_dialog = null
	reveal_button()
	
func reveal_button():
	$HBoxContainer/AddNewDialog.visible = true	
	
func hide_button():
	$HBoxContainer/AddNewDialog.visible = false


func _on_AddNewDialog_pressed():
	var new_name = "New Dialog"
	if $HBoxContainer/VBoxContainer/TextEdit.text != '':
		new_name = $HBoxContainer/VBoxContainer/TextEdit.text
	var node = get_parent().get_parent().add_dialog_node(offset+Vector2(320,-70),new_name)
	connected_dialog = node
	connected_dialog.connected_responses.append(self)
	graph.connect_node(self.get_name(),0,node.get_name(),0)
	$HBoxContainer/AddNewDialog.visible = false


func _on_OptionButton_item_selected(index):
	if index == 2:
		$HBoxContainer/VBoxContainer/CommandText.visible = true
	else:
		$HBoxContainer/VBoxContainer/CommandText.visible = false
	if index == 0:
		$HBoxContainer/AddNewDialog.visible = true
		set_slot_enabled_right(0,true)
		
	else:
		$HBoxContainer/AddNewDialog.visible = false
		set_slot_enabled_right(0,false)
		if connected_dialog != null:
			graph.disconnect_node(self.get_name(),0,connected_dialog.get_name(),0)
			connected_dialog.connected_responses.erase(self)
			connected_dialog = null


func _on_ColorPickerButton_color_changed(color):
	var colorHex = "0x"+String(color.to_html(false))
	color_decimal = colorHex.hex_to_int()
	
	
