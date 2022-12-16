extends Node

const RESPONSE_NODE_VERTICAL_OFFSET = 100
const DIALOG_NODE_HORIZONTAL_OFFSET = 320


var DIALOG_NODE = preload("res://src/Nodes/DialogNode.tscn")
var RESPONSE_NODE = preload("res://src/Nodes/ResponseNode.tscn")

enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 



var dialog_left_slot_color = Color(0,0,1)
var dialog_right_slot_color = Color(0,1,0)

var response_left_slot_color = Color(0,1,0)
var response_right_slot_color = Color(0,0,1)

var response_right_slot_color_hidden = Color(1,0,1)
var dialog_left_slot_color_hidden = Color(1,0,1)

func int_to_color(integer):
	var r = (integer >> 16) & 0xff
	var g = (integer >> 8) & 0xff
	var b = integer & 0xff
	var color = Color(1,1,1)
	color.r8 = r
	color.g8 = g
	color.b8 = b
	return color
