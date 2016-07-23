
extends Button

onready var g = get_tree().get_root().get_child(0)

func _ready():
	connect("pressed", self, '_clear')

func _clear():
	for child in g.main_graph.get_children():
		if child.is_in_group(g.gr_nodes_group):
			child.free()
	g.main_managers._ready()