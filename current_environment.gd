extends Node

var current_directory
var current_dialog_directory
var current_category_name
var highest_id = 0 setget set_highest_id
var loading_stage = false

func _ready():
	pass

func set_highest_id(new_id):
	highest_id = new_id
	var file = File.new()
	file.open(current_directory+"/dialogs/highest_index.json",File.WRITE)
	file.store_line(String(highest_id))
