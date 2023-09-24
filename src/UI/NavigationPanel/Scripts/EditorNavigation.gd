extends Panel
signal save_category_request
signal export_category_request
signal reimport_category_request
signal scan_for_changes_request


func _on_SaveButton_pressed():
	emit_signal("save_category_request")



func _on_ExportButton_pressed():
	emit_signal("export_category_request")


func _on_ReimportButton_pressed():
	emit_signal("reimport_category_request")
	


func _on_ScanButton_pressed():
	emit_signal("scan_for_changes_request")


func _on_DialogEditor_finished_loading(category_name : String):
	$TopPanelContainer.visible = true
	
func _input(event):
	if $TopPanelContainer.visible && !GlobalDeclarations.assigning_keybind:
		if event.is_action("save"):
			emit_signal("save_category_request")
		if event.is_action("export"):
			emit_signal("export_category_request")
		if event.is_action("reimport_category"):
			emit_signal("reimport_category_request")
		if event.is_action("scan_for_changes"):
			emit_signal("scan_for_changes_request")
