#
#-when pressed, add node selected in node_selector to main_graph
#
extends Button

onready var g = get_tree().get_root().get_child(0)

func _ready():
	connect("pressed", self, '_add_selected')

func _add_selected():
	var gr_node = g.node_selector.get_selected_type()
	g.main_graph.create_gr_node(gr_node, '', '')