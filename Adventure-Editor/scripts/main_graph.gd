#
#-has methods for note templating/creation (each return created node)
#-allow: (dis)connection b/w nodes, node deleltion,/duplication, etc.
#
extends GraphEdit

onready var g = get_tree().get_root().get_child(0)

func _ready():
	set_right_disconnects(true)
	OS.set_low_processor_usage_mode(true)
	connect('connection_request', self, '_connect')
	connect('disconnection_request', self, '_disconnect')

func create_gr_node(name, data, uniq_name): #data= {"position":"value",...}
	var gr_node = g.node_selector.gr_nodes[name].instance()
	add_child(gr_node)
	if data != '':
		gr_node.set_data(data)
		var pos = data["position"].split(',')
		gr_node.set_offset(Vector2(pos[0], pos[1]))
	
	if uniq_name != '':
		gr_node.set_name(uniq_name)
	else:
		gr_node.set_name(gr_node.get_name().substr(0, gr_node.get_name().length()))


func _connect(from, from_slot, to, to_slot):
	var conn_arr = get_connection_list()
	for conn in conn_arr:
		if (conn['from'] == from) && (conn['from_port'] == from_slot):
			var to_conn_count = get_node(to).get_connection_input_count()
			while to_conn_count >= 0:
				disconnect_node(conn['from'], conn['from_port'], conn['to'], to_conn_count)
				to_conn_count = to_conn_count - 1
				
	connect_node(from, from_slot, to, to_slot)
	

func _disconnect(from, from_slot, to, to_slot):
	disconnect_node(from, from_slot, to, to_slot)