extends Panel
signal save_category_request
signal export_category_request



onready var file_button = $TopPanelContainer/File



func _ready():
	var file_popup = file_button.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")

func file_menu(id):
	match id:
		2:
			emit_signal("save_category_request")
		9:
			emit_signal("export_category_request")


	


	

	


