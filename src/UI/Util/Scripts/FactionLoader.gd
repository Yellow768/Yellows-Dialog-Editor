class_name faction_loader
extends Node
var slot_bytes_identifier : PoolByteArray = [83, 108, 111, 116]
var name_bytes_identifier : PoolByteArray = [78, 97, 109, 101]
#For some reason, I can't declare these as a const

signal faction_dict_created
signal no_faction_data


func get_faction_data(directory):
	var file = File.new()
	var faction_file = file.open(directory+"/factions.dat",File.READ)
	if faction_file == OK:
		return create_faction_dict_from_dat_file(file)
	else:
		return {}

func is_valid_faction_data(file : File):
	if file.get_len() > 6144:
		printerr("Factions file is too large. Contact Yellow768")
		return false
	var first_bytes : PoolByteArray = file.get_buffer(file.get_len()).decompress_dynamic(-1,File.COMPRESSION_GZIP)
	if first_bytes == PoolByteArray([]):
		
		printerr("Could not decompress faction file")
		return false
	if first_bytes.subarray(0,16) != PoolByteArray([10, 0, 0, 9, 0, 11, 78, 80, 67, 70, 97, 99, 116, 105, 111, 110, 115]):
		printerr("Not a valid faction.dat file.")
		return false
	return true
		


func create_faction_dict_from_dat_file(file : File):
	#Uncompress the dat file, giving us the raw bytes of data
	var uncompressed_dat_file : PoolByteArray = file.get_buffer(file.get_len()).decompress_dynamic(-1,File.COMPRESSION_GZIP)
	var faction_dict = {}
	var cursor_position = 0
	var test_string = ""
	while cursor_position < uncompressed_dat_file.size():
		var s_slot = uncompressed_dat_file.find(83,cursor_position)
		if s_slot == -1:
			break
		if uncompressed_dat_file.subarray(s_slot,s_slot+3) != slot_bytes_identifier:
			cursor_position = s_slot+3
		else:
			var id = convert_bytes_to_s32(uncompressed_dat_file.subarray(s_slot+4,s_slot+7))
			var fact_name = find_faction_name_from_bytes(uncompressed_dat_file,s_slot+7)
			faction_dict[fact_name] = id
			cursor_position = s_slot+7
	
	return faction_dict


func find_faction_name_from_bytes(bytes,starting_pos):
	var name_cursor_position = starting_pos
	while name_cursor_position < bytes.size():
		var n_name = bytes.find(78,name_cursor_position)
		if(bytes.subarray(n_name,n_name+3)) != name_bytes_identifier:
			name_cursor_position = n_name+3
			print(String(bytes.subarray(n_name,n_name+3))+" is not the name identifier. Continuing")
		else:
			var name_size = convert_bytes_to_s16(bytes.subarray(n_name+4,n_name+5))
			var fact_name = bytes.subarray(n_name+6,n_name+6+name_size).get_string_from_utf8()
			return fact_name
		


func convert_bytes_to_s32(bytes : PoolByteArray):
	var spb = StreamPeerBuffer.new()
	spb.big_endian = true
	spb.data_array = bytes
	return spb.get_32()
	
func convert_bytes_to_s16(bytes: PoolByteArray):
	var spb = StreamPeerBuffer.new()
	spb.big_endian = true
	spb.data_array = bytes
	return spb.get_16()
	
	



