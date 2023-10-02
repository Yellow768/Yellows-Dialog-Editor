extends Panel

signal request_load_category
signal request_clear_editor
signal request_dialog_ids_reassigned


signal set_category_file_path

signal reveal_category_panel
signal hide_category_panel
signal reimport_category
signal current_category_deleted
signal scan_for_changes


signal category_succesfully_saved
signal category_failed_save

signal finished_loading
signal category_succesfully_exported
signal category_export_failed
signal unsaved_change

@export var category_file_container_path: NodePath
@export var environment_index_path: NodePath
@export var dialog_editor_path : NodePath
@export var auto_save_path : NodePath

var loading_category : bool = false

var current_directory_path
var current_category
var current_category_button : Button

var export_version : int = 2



@onready var CategoryFileContainer = get_node(category_file_container_path)
@onready var EnvironmentIndex = get_node(environment_index_path)
@onready var DialogEditor = get_node(dialog_editor_path)
@onready var AutoSave = get_node(auto_save_path)


var categoryPanelRevealed = false
var category_temp_data : Dictionary = {}


func _ready():
	create_category_buttons(EnvironmentIndex.index_categories())
	EnvironmentIndex.connect("category_duplicated",Callable(self,"load_duplicated_category"))

	

func create_category_buttons(categories):
	for node in CategoryFileContainer.get_children():
		node.queue_free()
	for i in categories:
		var category_button = load("res://src/Nodes/CategoryButton.tscn").instantiate()
		category_button.index = categories.find(i)
		category_button.category_name = i
		category_button.toggle_mode = true
		category_button.button_group  = load("res://Assets/CategoryButtons.tres")
		category_button.theme_type_variation = "CategoryButton"
		category_button.connect("open_category_request", Callable(self, "load_category"))
		category_button.connect("rename_category_request", Callable(EnvironmentIndex, "rename_category"))
		category_button.connect("reimport_category_request", Callable(self, "reimport_category_popup"))
		category_button.connect("delete_category_request", Callable(self, "request_deletion_popup"))
		category_button.connect("duplicate_category_request", Callable(EnvironmentIndex, "duplicate_category"))
		CategoryFileContainer.add_child(category_button)
	
		







func _process(delta):
	if (categoryPanelRevealed and not Rect2(Vector2(),size).has_point(get_local_mouse_position())) or get_global_mouse_position().x < 0:
		emit_signal("hide_category_panel")
		categoryPanelRevealed = false
	if !categoryPanelRevealed and Rect2(Vector2(),size).has_point(get_local_mouse_position()) and get_global_mouse_position().x > 0:
		emit_signal("reveal_category_panel")
		categoryPanelRevealed = true



func _on_CreateNewCategory_pressed():
	var confirm_text_popup = load("res://src/UI/Util/TextEnterConfirmTemplate.tscn").instantiate()
	confirm_text_popup.connect("confirmed_send_text", Callable(EnvironmentIndex, "create_new_category"))
	confirm_text_popup.connect("confirmed_send_text", Callable(self, "load_category"))
	#confirm_text_popup.rect_position = OS.window_size/2
	$".".add_child(confirm_text_popup)
	confirm_text_popup.popup_centered()

func request_deletion_popup(deletion_name):
	var confirm_deletion_popup = load("res://src/UI/Util/ConfirmDeletion.tscn").instantiate()
	confirm_deletion_popup.connect("confirmed", Callable(EnvironmentIndex, "delete_category").bind(deletion_name))
	confirm_deletion_popup.dialog_text = "Are you sure you want to delete "+deletion_name+"?\nAll dialogs will be deleted."
	$".".add_child(confirm_deletion_popup)
	confirm_deletion_popup.popup_centered()
	if deletion_name == current_category:
		confirm_deletion_popup.connect("confirmed", Callable(self, "emit_signal").bind("current_category_deleted"))

func reimport_category_popup(reimport_name):
	var confirm_reimport_popup = load("res://src/UI/Util/ConfirmDeletion.tscn").instantiate()
	confirm_reimport_popup.connect("confirmed", Callable(self, "initialize_category_import").bind(reimport_name))
	confirm_reimport_popup.dialog_text = "Are you sure you want to reimport "+reimport_name+"? All current dialog nodes will be permanently deleted. The category will create new nodes from the existing JSON files in the directory."
	$".".add_child(confirm_reimport_popup)
	confirm_reimport_popup.popup_centered()


func _on_TopPanel_reimport_category_request():
	reimport_category_popup(current_category)


func _on_DialogEditor_finished_importing(category_name):
	current_category = category_name


func _on_DialogEditor_finished_loading(category_name):
	current_category = category_name
	loading_category = false



func _on_TopPanel_scan_for_changes_request():
	emit_signal("scan_for_changes",current_category)
	
var stored_category


func _on_InformationPanel_request_store_current_category():
	stored_category = current_category
	



func _on_InformationPanel_request_switch_to_stored_category():
	if stored_category != current_category:
		emit_signal("request_load_category",stored_category)


func _on_InformationPanel_availability_mode_entered():
	stored_category = current_category	

func save_category_request():
	if current_category == null:
		emit_signal("category_failed_save")
		return
	var cat_save = category_saver.new()
	add_child(cat_save)
	if cat_save.save_category(current_category) == OK:
		emit_signal("category_succesfully_saved",current_category)
		current_category_button.set_unsaved(false)
	else:
		emit_signal("category_failed_save")


func save_all_categories():
	for key in category_temp_data.keys():
		var cat_save = category_saver.new()
		add_child(cat_save)
		if cat_save.save_category(key,category_temp_data[key]) == OK:
			emit_signal("category_succesfully_saved",current_category)
		else:
			emit_signal("category_failed_save")
	emit_signal("unsaved_change",false)

	
func save_all_backups():
	print(category_temp_data.keys())
	for key in category_temp_data.keys():
		var cat_save = category_saver.new()
		add_child(cat_save)
		
		DirAccess.make_dir_absolute(CurrentEnvironment.current_directory+"/"+key+"/autosave")
		if cat_save.save_category(key,category_temp_data[key],true) == OK:
			emit_signal("category_succesfully_saved",current_category)
		else:
			emit_signal("category_failed_save")
	emit_signal("unsaved_change",false)



func export_category_request():
	if current_category == null:
		emit_signal("category_export_failed",current_category)
		return
	var cat_exp = category_exporter.new()
	add_child(cat_exp)
	cat_exp.export_category(CurrentEnvironment.current_directory+"/dialogs/",current_category,export_version)
	cat_exp.queue_free()
	emit_signal("category_succesfully_exported",current_category)
	

	
func load_category(category_name : String,category_button : Button = null):
	
	if !loading_category and category_name != current_category:
		loading_category = true
		if category_button == null :
			for child in CategoryFileContainer.get_children():
				if child.category_name == current_category:
					child.button_pressed = true
					category_button = child
	current_category_button = category_button
	if current_category != null:
		print(current_category)
		var temp_cat_saver = category_saver.new()
		add_child(temp_cat_saver)
		category_temp_data[current_category] = temp_cat_saver.save_temp(current_category)
		
	current_category = category_name
	CurrentEnvironment.current_category_name = current_category
	var new_category_loader := category_loader.new()
	new_category_loader.connect("add_dialog", Callable(DialogEditor, "add_dialog_node"))
	new_category_loader.connect("add_response", Callable(DialogEditor, "add_response_node"))
	new_category_loader.connect("no_ydec_found", Callable(self, "initialize_category_import"))
	new_category_loader.connect("clear_editor_request", Callable(DialogEditor, "clear_editor"))
	new_category_loader.connect("request_connect_nodes", Callable(DialogEditor, "connect_nodes"))
	new_category_loader.connect("editor_offset_loaded", Callable(DialogEditor, "set_scroll_ofs"))
	new_category_loader.connect("request_add_color_organizer", Callable(DialogEditor, "add_color_organizer"))
	new_category_loader.connect("zoom_loaded", Callable(DialogEditor, "set_zoom"))
	if category_temp_data.has(category_name):
		if new_category_loader.load_temp(category_temp_data[category_name]) == OK:
			emit_signal("finished_loading",category_name)
			DialogEditor.visible = true
	else:
		if new_category_loader.load_category(category_name) == OK:
			emit_signal("finished_loading",category_name)
			DialogEditor.visible = true
			print(current_category+" after")
			var temp_cat_saver = category_saver.new()
			add_child(temp_cat_saver)
			category_temp_data[current_category] = temp_cat_saver.save_temp(current_category)
		
	current_category = category_name
	loading_category = false
		
	
func initialize_category_import(category_name : String):
	DialogEditor.visible = false
	var choose_dialog_popup = load("res://src/UI/Util/ChooseInitialDialogPopup.tscn").instantiate()
	choose_dialog_popup.connect("initial_dialog_chosen", Callable(self, "import_category"))
	choose_dialog_popup.connect("import_canceled", Callable(DialogEditor, "import_canceled"))
	choose_dialog_popup.connect("no_dialogs", Callable(DialogEditor, "on_no_dialogs").bind(category_name))
	get_parent().add_child(choose_dialog_popup)
	choose_dialog_popup.size = get_window().size
	choose_dialog_popup.position = Vector2(0,0)
	choose_dialog_popup.create_dialog_buttons(category_name)
	request_clear_editor.emit()
	
func import_category(category_name : String,all_dialogs : Array[Dictionary],index : int):
	CurrentEnvironment.current_category_name = null
	CurrentEnvironment.allow_save_state = false
	var new_category_importer := category_importer.new()
	new_category_importer.connect("request_add_dialog", Callable(DialogEditor, "add_dialog_node"))
	new_category_importer.connect("request_add_response", Callable(DialogEditor, "add_response_node"))
	new_category_importer.connect("request_connect_nodes", Callable(DialogEditor, "connect_nodes"))
	new_category_importer.connect("clear_editor_request", Callable(DialogEditor, "clear_editor"))
	new_category_importer.connect("editor_offset_loaded", Callable(DialogEditor, "set_scroll_ofs"))
	new_category_importer.connect("save_category_request",Callable(DialogEditor,"emit_signal").bind("request_save"))
	new_category_importer.initial_dialog_chosen(category_name,all_dialogs,index)
	emit_signal("finished_loading",category_name)
	current_category = category_name
	DialogEditor.visible = true
	DisplayServer.window_set_title(CurrentEnvironment.current_directory+"/"+category_name+" | CNPC Dialog Editor")

func _on_Searchbar_text_changed(new_text : String):
	for button in $VBoxContainer/ScrollContainer/CategoryContainers.get_children():
		if new_text == "":
			button.visible = true
		else:
			if new_text.capitalize() in button.text.capitalize():
				button.visible = true
			else:
				button.visible = false


func _on_export_type_button_item_selected(index:int):
	export_version = index

func load_duplicated_category(name : String):
	save_category_request()
	load_category(name)
	emit_signal("request_dialog_ids_reassigned")
	


func _on_dialog_editor_import_category_canceled():
	current_category = null
	current_category_button = null
	CurrentEnvironment.current_category_name = null
	#create_category_buttons(EnvironmentIndex.index_categories())


func _on_dialog_editor_unsaved_changes(name):
	if current_category_button != null && !loading_category:
		current_category_button.set_unsaved(true)


func _on_autosave_timer_timeout():
	save_all_backups()
	print("saving backups")
	AutoSave.start(GlobalDeclarations.autosave_time*60)


func _on_editor_settings_autosave_time_changed():
	AutoSave.start(GlobalDeclarations.autosave_time*60)
