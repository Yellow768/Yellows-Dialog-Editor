extends Panel

onready var file_button = $TopPanelContainer/File


func _ready():
	var file_popup = file_button.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")

func save():
	var save_nodes = get_tree().get_nodes_in_group("Save")
	for i in save_nodes:
		i.save()

func file_menu(id):
	match id:
		2:
			save()
