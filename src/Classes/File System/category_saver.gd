class_name category_saver
extends Node

signal category_saved
	
func save_category(category_name,data = null):
	if CurrentEnvironment.current_directory != null && category_name != null :
		var save_category = FileAccess.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec",FileAccess.WRITE)
		if data != null:
			for datum in data:
				save_category.store_line(JSON.new().stringify(datum))
			save_category.close()
			emit_signal("category_saved")
			queue_free()	
			return OK
		var save_nodes = get_tree().get_nodes_in_group("Save")
		for node in save_nodes:
			if node.scene_file_path.is_empty():
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
		queue_free()
		return OK
	else:
		print("Nothing To Save")
		queue_free()
		return ERR_DOES_NOT_EXIST
		
func save_temp(category_name):
	if CurrentEnvironment.current_directory != null && category_name != null :
		var temp_data = []
		var save_nodes = get_tree().get_nodes_in_group("Save")
		
		for node in save_nodes:
			if node.scene_file_path.is_empty():
				print("Node '%s' is not instanced, skipped" % node.name)
				continue
			
			if !node.has_method("save"):
				print("Node '%s' is missing a save() function, skipped" % node.name)
				continue
			
			var category_data = node.call("save")
			
			temp_data.append(category_data)
		var editors = get_tree().get_nodes_in_group("editor")
		for editor in editors:
			var editor_data = editor.call("save")
			temp_data.append(editor_data)
		queue_free()
		return temp_data
	


	
