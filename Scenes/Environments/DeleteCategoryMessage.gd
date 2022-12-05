extends ConfirmationDialog

var category_name

func _ready():
	pass





func deletion_message(text):
	category_name = text
	popup_centered()


func _on_ConfirmDeletion_modal_closed():
	queue_free()
