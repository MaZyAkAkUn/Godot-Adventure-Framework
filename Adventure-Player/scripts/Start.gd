
extends GraphNode

const ref_name = 'Start'
signal GR_NODE_DONE
var implied_port = 0

func _ready():
	connect('close_request', self, '_close')
func _close():
	self.queue_free()

func set_data(data):
	pass

func get_data():
	var data = {}
	data["ref_name"] = ref_name
	return data

func get_implied_from_port():
	return implied_port

func action(data, gaf_file, init_object, public_node, view_shield):
	#data: data in same format as that set by self (set_data())
	#gaf_file: read-only that includes .options & .characters
	#init_object: read & write object that has scirpt written in init manager
	#init_object is the only thing saved to disk as far as you are concerned
	#you return an integer 0 to n that specifies next slot (for paths)
	emit_signal('GR_NODE_DONE')
