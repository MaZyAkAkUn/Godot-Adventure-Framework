#
#-when pressed, attempt loading file in path_selector into main_graph
#--file doesn't exist, or other error
#--file exists, clear & load file content to main_graph
#-This button is also used for the managers
#
extends Button

onready var g = get_tree().get_root().get_child(0)

func _ready():
	connect("pressed", self, '_load_data')

func _load_data():
	var path_to_load = g.path_selector.get_text()
	var file = File.new()
	
	if !file.file_exists(path_to_load):
		g.path_selector.file_error()
		return
	
	file.open(path_to_load, file.READ)
	g.gaf_file.parse_json(file.get_as_text())
	
	file.close()
	load_into_graph(g.gaf_file)
	load_into_managers(g.gaf_file)
	g.path_selector.file_success()

func load_into_graph(data_dict):
	for child in g.main_graph.get_children():
		if child.is_in_group(g.gr_nodes_group):
			child.free()
	var cont_dict = data_dict["content"] #{"name":{"property":"value",...},...}
	var conn_arr = data_dict["connections"] #[{from_slot: 0, from: “name”, to_slot: 0, to: “name” },...]
	#load content
	for cont in cont_dict: #cont= "name"
		print(cont)
		g.main_graph.create_gr_node(cont_dict[cont]["ref_name"], cont_dict[cont], cont)
	#load connections
	for conn in conn_arr: #conn= {from_slot: 0, from: “name”, to_slot: 0, to: “name” }
		print(conn)
		g.main_graph.connect_node(conn['from'], conn['from_port'], conn['to'], conn['to_port'])

func load_into_managers(data_dict):
	g.main_managers.get_node("init/TextEdit").set_text(data_dict["init"])
	g.main_managers.get_node("characters/TextEdit").set_text(data_dict["characters_plaintext"])
	g.main_managers.get_node("options/TextEdit").set_text(data_dict["options_plaintext"])