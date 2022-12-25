extends FileDialog

func _ready():
	popup()


func _on_FileDialog_file_selected(path):
	var file = File.new()
	var other_file = File.new()
	var fct_load = faction_loader.new()
	file.open(path,File.READ)
	other_file.open("F:\\Daruma Project\\Isles of Rainmire Directory\\Tools\\output.txt",File.WRITE)
	other_file.store_string(String(fct_load.create_faction_dict_from_dat_file(file)))
	
	file.close()
	other_file.close()


func _on_FileDialog_popup_hide():
	popup()
