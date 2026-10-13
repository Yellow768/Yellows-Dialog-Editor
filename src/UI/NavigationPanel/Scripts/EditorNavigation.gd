extends Panel
signal save_category_request
signal export_category_request
signal reimport_category_request
signal scan_for_changes_request
signal assign_new_ids_request
signal deselect_all_selected
signal rescan_quests_and_factions

func _ready():
	get_tree().get_root().size_changed.connect(Callable(self,"resized"))
	$TopPanelContainer/SecSep3.custom_minimum_size.x = DisplayServer.window_get_size().x/50
	$TopPanelContainer/SecSep2.custom_minimum_size.x = DisplayServer.window_get_size().x/50
	$TopPanelContainer/SecSep4.custom_minimum_size.x = DisplayServer.window_get_size().x/50
	$TopPanelContainer/MenuButton.get_popup().connect("id_pressed",Callable(self,"category_menu_pressed"))
	$TopPanelContainer/ExportTypeButton.selected = GlobalDeclarations.last_used_export_version

func _on_SaveButton_pressed():
	save_category_request.emit()



func _on_ExportButton_pressed():
	export_category_request.emit()


func _on_ReimportButton_pressed():
	reimport_category_request.emit()
	


func _on_ScanButton_pressed():
	scan_for_changes_request.emit()


func _on_DialogEditor_finished_loading(category_name : String):
	$TopPanelContainer.visible = true


func category_menu_pressed(id):
	match id:
		0:
			reimport_category_request.emit()
		1:
			scan_for_changes_request.emit()
		2:
			assign_new_ids_request.emit()
		3:
			deselect_all_selected.emit()
		4:
			show_category_settings()
		5:
			rescan_quests_and_factions.emit()

func _input(event):
	if $TopPanelContainer.visible && !GlobalDeclarations.assigning_keybind:
		if Input.is_action_just_pressed("save"):
			save_category_request.emit()
			accept_event()
		if Input.is_action_just_pressed("export"):
			export_category_request.emit()
			accept_event()	
		if Input.is_action_just_pressed("reimport_category"):
			reimport_category_request.emit()
			accept_event()	
		if Input.is_action_just_pressed("scan_for_changes"):
			scan_for_changes_request.emit()
			accept_event()	


func _on_category_panel_finished_loading(_ignore : String):
	$TopPanelContainer.visible = true


func _on_dialog_editor_import_category_canceled():
	$TopPanelContainer.visible = false



func show_category_settings():
	var category_settings = load("res://src/UI/Editor/CategorySettings.tscn").instantiate()
	get_parent().add_child(category_settings)

func _on_rescan_quests_and_factions_pressed():
	pass # Replace with function body.





func _on_sftp_box_resync_cache():
	$TopPanelContainer.visible = false


func _on_category_panel_current_category_deleted():
	$TopPanelContainer.visible = false

func resized():
	$TopPanelContainer/SecSep3.custom_minimum_size.x = DisplayServer.window_get_size().x/50
	$TopPanelContainer/SecSep2.custom_minimum_size.x = DisplayServer.window_get_size().x/50
	$TopPanelContainer/SecSep4.custom_minimum_size.x = DisplayServer.window_get_size().x/50
