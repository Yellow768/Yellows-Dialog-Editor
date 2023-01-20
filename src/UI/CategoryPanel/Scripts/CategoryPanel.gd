extends Panel

signal request_load_category
signal set_category_file_path

signal reveal_category_panel
signal hide_category_panel
signal reimport_category
signal current_category_deleted
signal scan_for_changes

signal category_succesfully_saved
signal category_failed_save

signal category_succesfully_exported
signal category_export_failed

export(NodePath) var animation_player_path
export(NodePath) var category_file_container_path
export(NodePath) var environment_index_path

var loading_category : bool = false

var current_directory_path
var current_category


onready var animation_player = get_node(animation_player_path)
onready var category_file_container = get_node(category_file_container_path)
onready var EnvironmentIndex = get_node(environment_index_path)


var categoryPanelRevealed = false

func _ready():
	rect_position = Vector2(-290,50)
	create_category_buttons(EnvironmentIndex.index_categories())

	

func create_category_buttons(categories):
	for node in category_file_container.get_children():
		node.queue_free()
	for i in categories:
		var category_button = load("res://src/Nodes/CategoryButton.tscn").instance()
		category_button.index = categories.find(i)
		category_button.text = i
		category_button.toggle_mode = true
		category_button.group  = load("res://Assets/CategoryButtons.tres")
		category_button.theme_type_variation = "CategoryButton"
		category_button.connect("open_category_request",self,"_category_button_pressed")
		category_button.connect("rename_category_request",EnvironmentIndex,"rename_category")
		category_button.connect("reimport_category_request",self,"reimport_category_popup")
		category_button.connect("delete_category_request",self,"request_deletion_popup")
		category_file_container.add_child(category_button)
	
		


func _category_button_pressed(category_button):
	
	if !loading_category and category_button.text != current_category:
		loading_category = true
		var new_saver = category_saver.new()
		add_child(new_saver)
		new_saver.save_category(current_category)
		emit_signal("request_load_category",category_button.text)


func _on_CategoryPanel_mouse_entered():
	if !categoryPanelRevealed:
		emit_signal("reveal_category_panel")
		categoryPanelRevealed = true




func _on_CategoryPanel_mouse_exited():
	if not Rect2(Vector2(),rect_size).has_point(get_local_mouse_position()):
		emit_signal("hide_category_panel")
		categoryPanelRevealed = false





func _on_CreateNewCategory_pressed():
	var confirm_text_popup = load("res://src/UI/Util/TextEnterConfirmTemplate.tscn").instance()
	confirm_text_popup.connect("confirmed_send_text",EnvironmentIndex,"create_new_category")
	#confirm_text_popup.rect_position = OS.window_size/2
	$".".add_child(confirm_text_popup)
	confirm_text_popup.popup_centered()

func request_deletion_popup(deletion_name):
	var confirm_deletion_popup = load("res://src/UI/Util/ConfirmDeletion.tscn").instance()
	confirm_deletion_popup.connect("confirmed",EnvironmentIndex,"delete_category",[deletion_name])
	confirm_deletion_popup.dialog_text = "Are you sure you want to delete "+deletion_name+"?\nAll dialogs will be deleted."
	$".".add_child(confirm_deletion_popup)
	confirm_deletion_popup.popup_centered()
	if deletion_name == current_category:
		confirm_deletion_popup.connect("confirmed",self,"emit_signal",["current_category_deleted"])

func reimport_category_popup(reimport_name):
	var confirm_reimport_popup = load("res://src/UI/Util/ConfirmDeletion.tscn").instance()
	confirm_reimport_popup.connect("confirmed",self,"emit_signal",["reimport_category",reimport_name])
	confirm_reimport_popup.dialog_text = "Are you want to reimport "+reimport_name+"? All current dialog nodes will be permanently deleted. The category will create new nodes from the existing JSON files in the directory."
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


func save_category_request():
	if current_category == null:
		emit_signal("category_failed_save")
		return
	var cat_save = category_saver.new()
	add_child(cat_save)
	if cat_save.save_category(current_category) == OK:
		emit_signal("category_succesfully_saved",current_category)
	else:
		emit_signal("category_failed_save")


func _on_InformationPanel_availability_mode_entered():
	stored_category = current_category


func _on_TopPanel_export_category_request():
	if current_category == null:
		emit_signal("category_export_failed",current_category)
		return
	var cat_exp = category_exporter.new()
	add_child(cat_exp)
	cat_exp.export_category(CurrentEnvironment.current_directory+"/dialogs/",current_category)
	cat_exp.queue_free()
	emit_signal("category_succesfully_exported",current_category)
	


func _on_Searchbar_text_changed(new_text : String):
	for button in $VBoxContainer/ScrollContainer/CategoryContainers.get_children():
		if new_text == "":
			button.visible = true
		else:
			if new_text.capitalize() in button.text.capitalize():
				button.visible = true
			else:
				button.visible = false
