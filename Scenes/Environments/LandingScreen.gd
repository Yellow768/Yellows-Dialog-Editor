extends Control
var chosen_dir

func _ready():
	OS.min_window_size = Vector2(1280,720)


func change_to_editor(directory):
	var editor = load("res://Scenes/Environments/MainEditor.tscn").instance()
	CurrentEnvironment.current_directory = directory
	get_parent().add_child(editor)
	queue_free()
	


func _on_Open_Environment_pressed():
	$Panel/FileDialog.popup()


func _on_FileDialog_confirmed():
	print("FileDialog_confirmed")
	



func _on_FileDialog_dir_selected(path):
	var dir = Directory.new()
	chosen_dir = path
	dir.open(path)
	if !dir.dir_exists(path+'/dialogs'):
		$Panel/InvalidFolderWarning.popup_centered()
	else:
		change_to_editor(path)


		


func _on_Cancel_button_up():
	$Panel/FileDialog.popup()
	$Panel/InvalidFolderWarning.visible = false


func _on_Confirm_pressed():
	var dir = Directory.new()
	dir.open(chosen_dir)
	dir.make_dir(chosen_dir+"/dialogs")
	change_to_editor(chosen_dir)
