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
			emit_signal("reimport_category_request",text)
		3:
			emit_signal("delete_category_request",text)
		4:
			emit_signal("duplicate_category_request",text)
