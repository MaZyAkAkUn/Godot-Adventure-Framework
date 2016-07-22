#
#-manages the gr_nodes
#-adds gr_nodes to node_selector (& manages its returns)
#
extends OptionButton

var _file_content = {} #format below, same as gr_node.cfg
var _node_id_dict = {} #{node_id: "node name type",...}
var gr_nodes = {} #{"node name type": preloaded_node_obj,...}
onready var g = get_tree().get_root().get_child(0)

#gr_nodes.cfg/file_content FORMAT:
#{
#	"node name type": "gr_node_path.scn",
#	"SEPARATOR": "this adds a separator"
#}

func _ready():
	var file = File.new()
	file.open(g.gr_nodes_file_path, file.READ) 
	_file_content.parse_json(file.get_as_text())
	file.close()
	register_selections()

func register_selections():
	var i = 0
	for gr_node in _file_content:
		if gr_node == 'SEPARATOR':
			self.add_separator()
		else:
			self.add_item(gr_node, i)
			gr_nodes[gr_node] = load(_file_content[gr_node])
			_node_id_dict[i] = gr_node
		i = i + 1

func get_selected_type():
	var selected_id = get_selected_ID()
	return _node_id_dict[selected_id]
