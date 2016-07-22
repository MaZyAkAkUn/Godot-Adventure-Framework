#
#-when pressed, attempt saving main_graph into file in path_selector
#--file doesn't exist, or other error
#--file exists, save to file
#-This button is also used for the managers
#
extends Button

onready var g = get_tree().get_root().get_child(0)

func _ready():
	connect("pressed", self, '_save_data')

func _save_data():
	var path_to_save = g.path_selector.get_text()
	var file = File.new()
	file.open(path_to_save, file.WRITE)
	
	g.gaf_file = load_from_graph_and_managers()
	file.store_string(g.gaf_file.to_json())
	
	file.close()
	g.path_selector.file_success()

func load_from_graph_and_managers():
	var data_dict = {}
	
	data_dict["init"] = g.main_managers.get_node("init/TextEdit").get_text()
	data_dict["characters"] = {}
	data_dict["characters"].parse_json(g.main_managers.get_node("characters/TextEdit").get_text())
	data_dict["characters_plaintext"] = g.main_managers.get_node("characters/TextEdit").get_text()
	data_dict["options"] = {}
	data_dict["options"].parse_json(g.main_managers.get_node("options/TextEdit").get_text())
	data_dict["options_plaintext"] = g.main_managers.get_node("options/TextEdit").get_text()
	data_dict["connections"] = g.main_graph.get_connection_list()
	data_dict["content"] = {}
	
	for gr_node in g.main_graph.get_children():
		if gr_node.is_in_group(g.gr_nodes_group):
			data_dict["content"][gr_node.get_name()] = gr_node.get_data()
			data_dict["content"][gr_node.get_name()]["position"] = gr_node.get_offset()
	return data_dict