class_name faction_loader
extends Node
var slot_bytes_identifier : PackedByteArray = [83, 108, 111, 116]
var name_bytes_identifier : PackedByteArray = [78, 97, 109, 101]
#For some reason, I can't declare these as a const

signal faction_dict_created
signal no_faction_data


func get_faction_data(directory):
	var faction_file = FileAccess.open(directory+"/factions.dat",FileAccess.READ)
	if faction_file==null:
		return {}
	if faction_file.get_error() == OK:
		var fac_dic = create_faction_dict_from_dat_file(faction_file)
		print(fac_dic)
		return fac_dic
	else:
		return {}

func is_valid_faction_data(file : FileAccess):
	if file.get_length() > 6144:
		printerr("Factions file is too large. Contact Yellow768")
		return false
	var first_bytes : PackedByteArray = file.get_buffer(file.get_length()).decompress_dynamic(-1,FileAccess.COMPRESSION_GZIP)
	if first_bytes == PackedByteArray([]):
		
		printerr("Could not decompress faction file")
		return false
	if first_bytes.slice(0,16) != PackedByteArray([10, 0, 0, 9, 0, 11, 78, 80, 67, 70, 97, 99, 116, 105, 111, 110, 115]):
		printerr("Not a valid faction.dat file.")
		return false
	return true
		


func create_faction_dict_from_dat_file(file : FileAccess):
	#Uncompress the dat file, giving us the raw bytes of data
	var uncompressed_dat_file : PackedByteArray = file.get_buffer(file.get_length()).decompress_dynamic(-1,FileAccess.COMPRESSION_GZIP)
	var faction_dict = {}
	var cursor_position = 0
	while cursor_position < uncompressed_dat_file.size():
		var s_slot = uncompressed_dat_file.find(83,cursor_position)
		if s_slot == -1:
			break
		if uncompressed_dat_file.slice(s_slot,s_slot+4) != slot_bytes_identifier:
			cursor_position = s_slot+4
			print(slot_bytes_identifier)
		else:
			var id = convert_bytes_to_s32(uncompressed_dat_file.slice(s_slot+4,s_slot+9))
			var fact_name = find_faction_name_from_bytes(uncompressed_dat_file,s_slot+7)
			faction_dict[fact_name] = id
			cursor_position = s_slot+7
	
	return faction_dict


func find_faction_name_from_bytes(bytes,starting_pos):
	
	var name_cursor_position = starting_pos
	while name_cursor_position < bytes.size():
		var n_name = bytes.find(78,name_cursor_position)
		if(bytes.slice(n_name,n_name+4)) != name_bytes_identifier:
			name_cursor_position = n_name+4
			print(String(bytes.slice(n_name,n_name+4))+" is not the name identifier. Continuing")
		else:
			var name_size = convert_bytes_to_s16(bytes.slice(n_name+5,n_name+6))
			var fact_name = bytes.slice(n_name+6,n_name+7+name_size).get_string_from_utf8()
			
			return fact_name
		


func convert_bytes_to_s32(bytes : PackedByteArray):
	var spb = StreamPeerBuffer.new()
	spb.big_endian = true
	spb.data_array = bytes
	return spb.get_32()
	
func convert_bytes_to_s16(bytes: PackedByteArray):
	var spb = StreamPeerBuffer.new()
	spb.big_endian = true
	spb.data_array = bytes
	return spb.get_16()
	
	



