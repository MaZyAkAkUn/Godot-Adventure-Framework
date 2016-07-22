
extends TabContainer

onready var init = get_node('init/TextEdit')
onready var characters = get_node('characters/TextEdit')
onready var options = get_node('options/TextEdit')

var init_text = """var variable_name = "variable value" """

var characters_text = """{
	"character name": "character scene path",
}"""

var options_text = """{
	"dialogue_scene": "res://resources/dialogue scenes/simple_blue.scn",
	"choice_scene": "res://resources/choice scenes/vertical_center.scn",
	"async": true,
	"max_chars_at_once": 2,
	"timeout": 0,
	"typewriter": true,
}"""

func _ready():
	init.set_text(init_text)
	characters.set_text(characters_text)
	options.set_text(options_text)
