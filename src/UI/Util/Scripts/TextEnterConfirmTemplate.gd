extends ConfirmationDialog
signal confirmed_send_text

var text

func _ready():
	register_text_enter($LineEdit)
	$LineEdit.grab_focus()

func _on_Confirm_Text_confirmed():
	emit_signal("confirmed_send_text",text)

func set_placeholder_text(text):
	$LineEdit.placeholder_text = text
	
func _on_LineEdit_text_changed(new_text : String):
	text = new_text


func _on_Confirm_Text_about_to_show():
	$LineEdit.call_deferred("grab_focus")
	
func set_secret(tf):
	$LineEdit.secret = tf

