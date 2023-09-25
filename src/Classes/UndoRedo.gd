extends Node
class_name UndoSystem

signal undo_saved
signal redo_saved

var undo_history = []
var redo_history = []
var dialog_editor

func save_undo(clear_redo = false):
	if !GlobalDeclarations.undo_enabled:
		return
	if CurrentEnvironment.allow_save_state:
		var cat_save = category_saver.new()
		add_child(cat_save)
		undo_history.push_back(cat_save.save_undoredo(CurrentEnvironment.current_category_name))
		if clear_redo:
			redo_history.clear()
	emit_signal("undo_saved")
	

func save_redo():
	if !GlobalDeclarations.undo_enabled:
		return
	if CurrentEnvironment.allow_save_state:
		print("redo save called")
		var cat_save = category_saver.new()
		add_child(cat_save)
		redo_history.push_back(cat_save.save_undoredo(CurrentEnvironment.current_category_name))
	emit_signal("redo_saved")
	
func undo():
	if !GlobalDeclarations.undo_enabled:
		return
	save_redo()
	CurrentEnvironment.allow_save_state = false
	if undo_history.is_empty():
		return
	var cat_load = category_loader.new()
	add_child(cat_load)
	cat_load.connect("clear_editor_request",Callable(dialog_editor, "clear_editor"))
	cat_load.connect("add_dialog", Callable(dialog_editor, "add_dialog_node"))
	cat_load.connect("add_response", Callable(dialog_editor, "add_response_node"))
	cat_load.connect("no_ydec_found", Callable(dialog_editor, "initialize_category_import"))
	cat_load.connect("request_connect_nodes", Callable(dialog_editor, "connect_nodes"))
	cat_load.connect("editor_offset_loaded", Callable(dialog_editor, "set_scroll_ofs"))
	cat_load.connect("request_add_color_organizer", Callable(dialog_editor, "add_color_organizer"))
	cat_load.connect("zoom_loaded", Callable(dialog_editor, "set_zoom"))
	cat_load.load_undoredo(undo_history.back())
	undo_history.pop_back()
	CurrentEnvironment.allow_save_state = true

	
func redo():
	if !GlobalDeclarations.undo_enabled:
		return
	save_undo()
	if redo_history.is_empty():
		return
	CurrentEnvironment.allow_save_state = false
	var cat_load = category_loader.new()
	cat_load.connect("clear_editor_request",Callable(dialog_editor, "clear_editor"))
	cat_load.connect("add_dialog", Callable(dialog_editor, "add_dialog_node"))
	cat_load.connect("add_response", Callable(dialog_editor, "add_response_node"))
	cat_load.connect("no_ydec_found", Callable(dialog_editor, "initialize_category_import"))
	cat_load.connect("request_connect_nodes", Callable(dialog_editor, "connect_nodes"))
	cat_load.connect("editor_offset_loaded", Callable(dialog_editor, "set_scroll_ofs"))
	cat_load.connect("request_add_color_organizer", Callable(dialog_editor, "add_color_organizer"))
	cat_load.connect("zoom_loaded", Callable(dialog_editor, "set_zoom"))
	cat_load.load_undoredo(redo_history.back())
	redo_history.pop_back()	
	CurrentEnvironment.allow_save_state = true


