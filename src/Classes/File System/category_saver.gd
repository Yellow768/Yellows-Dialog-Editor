class_name category_saver
extends Node

signal category_saved
	
func save_category(category_name):
	if CurrentEnvironment.current_directory != null && category_name != null :
		var save_category = File.new()
		var save_nodes = get_tree().get_nodes_in_group("Save")
		save_category.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec",File.WRITE)
		for node in save_nodes:
			if node.filename.is_empty():
				print("Node '%s' is not instanced, skipped" % node.name)
				continue
			
			if !node.has_method("save"):
				print("Node '%s' is missing a save() function, skipped" % node.name)
				continue
			
			var category_data = node.call("save")
			
			save_category.store_line(JSON.new().stringify(category_data))
		var editors = get_tree().get_nodes_in_group("editor")
		for editor in editors:
			var editor_data = editor.call("save")
			save_category.store_line(JSON.new().stringify(editor_data))
		save_category.close()
		emit_signal("category_saved")
		return OK
	else:
		print("Nothing To Save")
		return ERR_DOES_NOT_EXIST
	queue_free()


	
