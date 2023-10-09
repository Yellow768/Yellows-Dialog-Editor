extends Button
signal rename_category_request
signal delete_category_request
signal reimport_category_request
signal duplicate_category_request

var index := 0

signal open_category_request

var category_name
var unsaved = false

func _ready():
	text = category_name
	

func set_unsaved(value):
	if value:
		text = category_name+"(*)"
	else:
		text = category_name

func _on_Button_pressed():
	emit_signal("open_category_request",category_name,self)


func _on_Button_gui_input(event : InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				var selected_style = StyleBoxFlat.new()
				selected_style.bg_color = Color(.4,.19,37,.6)
				selected_style.set_corner_radius_all(3)
				selected_style.set_content_margin_all(4)
				add_theme_stylebox_override("pressed",selected_style)
				add_theme_stylebox_override("normal",selected_style)
				add_theme_stylebox_override("hover",selected_style)
				$PopupMenu.position = get_global_mouse_position()
				$PopupMenu.popup()


func _on_PopupMenu_mouse_exited():
	$PopupMenu.visible = false






func _on_LineEdit_text_entered(new_text: String):
	$LineEdit.visible = false
	emit_signal("rename_category_request",text,new_text)


func _on_popup_menu_id_pressed(id):
	match id:
		0:
			$LineEdit.visible = true
			$LineEdit.grab_focus()
			$LineEdit.text = text
			$LineEdit.caret_column = $LineEdit.text.length()
		2:
			emit_signal("reimport_category_request",category_name)
		3:
			emit_signal("delete_category_request",category_name)
		4:
			emit_signal("duplicate_category_request",category_name)
		6:
			OS.shell_open(CurrentEnvironment.current_dialog_directory+"/"+category_name)
		7: 
			$PopupMenu.visible = false
	


func _on_popup_menu_visibility_changed():
	if $PopupMenu.visible == false:
		remove_theme_stylebox_override("pressed")
		remove_theme_stylebox_override("normal")
		remove_theme_stylebox_override("hover")
