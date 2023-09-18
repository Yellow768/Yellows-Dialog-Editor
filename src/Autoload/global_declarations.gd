extends Node

const RESPONSE_NODE_VERTICAL_OFFSET := 100
const DIALOG_NODE_HORIZONTAL_OFFSET := 400


var DIALOG_NODE := preload("res://src/Nodes/DialogNode.tscn")
var RESPONSE_NODE := preload("res://src/Nodes/ResponseNode.tscn")

enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 


var dialog_left_slot_color := Color(0.172549, 0.239216, 0.592157)
var dialog_right_slot_color := Color(0.94902, 0.282353, 0.078431)

var response_left_slot_color := Color(0.94902, 0.282353, 0.078431)
var response_right_slot_color := Color(0.172549, 0.239216, 0.592157)

var response_right_slot_color_hidden := Color(1,0,1)
var dialog_left_slot_color_hidden := Color(1,0,1)

var hide_connection_distance := 1000

func int_to_color(integer : int) -> Color:
	var r = (integer >> 16) & 0xff
	var g = (integer >> 8) & 0xff
	var b = integer & 0xff
	var color = Color(1,1,1)
	color.r8 = r
	color.g8 = g
	color.b8 = b
	return color
