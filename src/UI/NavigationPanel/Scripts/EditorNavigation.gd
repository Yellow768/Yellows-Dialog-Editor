extends Panel
signal save_category_request
signal export_category_request
signal reimport_category_request
signal scan_for_changes_request
signal import_faction_popup

onready var file_button = $TopPanelContainer/File



func _ready():
	var file_popup = file_button.get_popup()
	var environment_popup = $TopPanelContainer/Environment.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")
	environment_popup.connect("id_pressed",self,"environment_menu")
	
func file_menu(id):
	match id:
		
		7:
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

func environment_menu(id):
	match id:
		0:
			emit_signal("import_faction_popup")
	


	

	


