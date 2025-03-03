extends Control

signal input_recieved

var unsaved_categories = []


@export var _dialog_editor_path: NodePath
@export var _category_list_path: NodePath
@export var _information_panel_path: NodePath
@export var _dialog_settings_tabs_path: NodePath
@export var _top_panel_path: NodePath



@onready var DialogEditor := get_node(_dialog_editor_path)
@onready var InformationPanel := get_node(_information_panel_path)
@onready var DialogSettingsPanel := get_node(_dialog_settings_tabs_path)
@onready var CategoryList := get_node(_category_list_path)
@onready var TopPanel := get_node(_top_panel_path)


func _ready():
	get_tree().auto_accept_quit = false
	$AutosaveTimer.start(GlobalDeclarations.autosave_time*60)
	$DialogEditor.use_snap = GlobalDeclarations.snap_enabled
	
func _input(event : InputEvent):
	emit_signal("input_recieved", event)
	
var is_quit_return_to_home := false

func _on_HomeButton_pressed():
	if unsaved_categories.is_empty():
		get_parent().add_child(load("res://src/UI/LandingScreen.tscn").instantiate())
		queue_free()
	else:
		$UnsavedPanel.visible = true
		is_quit_return_to_home = true
		update_unsaved_categories_text_list()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		is_quit_return_to_home = false
		if unsaved_categories.is_empty():
			get_tree().quit()
			CurrentEnvironment.sftp_client.Disconnect()
		else:
			$UnsavedPanel.visible = true
			update_unsaved_categories_text_list()

func update_unsaved_categories_text_list():
	$UnsavedPanel/VBoxContainer/UnsavedCategoriesLabel.text = ""
	for category_name in unsaved_categories:
		$UnsavedPanel/VBoxContainer/UnsavedCategoriesLabel.text += category_name+"\n"
					
func add_to_unsaved_categories(category):
	if !unsaved_categories.has(category) && category != null:
		unsaved_categories.append(category)

func remove_from_unsaved_categories(category):
	unsaved_categories.erase(category)


func _on_no_save_pressed():
	if CurrentEnvironment.sftp_client:
		CurrentEnvironment.sftp_client.Disconnect()
	if is_quit_return_to_home:
		get_parent().add_child(load("res://src/UI/LandingScreen.tscn").instantiate())
		get_tree().auto_accept_quit = true
		queue_free()	
	else:
		get_tree().quit()
		


func _on_save_and_close_pressed():
	$CategoryPanel.save_all_categories()
	if is_quit_return_to_home:
		get_parent().add_child(load("res://src/UI/LandingScreen.tscn").instantiate())
		get_tree().auto_accept_quit = true
		queue_free()
	else:
		get_tree().quit()


func _on_cancel_pressed():
	$UnsavedPanel.visible = false


func _on_category_panel_category_succesfully_saved(category_name):
	remove_from_unsaved_categories(category_name)





func _on_dialog_editor_node_double_clicked(_ignore):
	$DoubleClickTimer.start()


func _on_dialog_file_system_index_category_deleted(category):
	remove_from_unsaved_categories(category)
