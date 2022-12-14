extends Panel
signal save_category_request
signal export_category_request
signal reimport_category_request
signal scan_for_changes_request

onready var file_button = $TopPanelContainer/File



func _ready():
	var file_popup = file_button.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")

func file_menu(id):
	match id:
		
		2:
			emit_signal("save_category_request")
		3:
			emit_signal("scan_for_changes_request")
		4:
			emit_signal("reimport_category_request")
		9:
			emit_signal("export_category_request")
		11:
			var landing_page = load("res://Scenes/Environments/LandingScreen.tscn").instance()
			get_parent().get_parent().add_child(landing_page)
			get_parent().queue_free()


	


	

	


