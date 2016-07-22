
extends LineEdit

func file_error(): #called when an IO error encountered
	var th = Theme.new()
	th.set_color("font_color","LineEdit",Color(255, 0, 0, 1))
	self.set_theme(th)

func file_success():
	var th = Theme.new()
	th.set_color("font_color","LineEdit",Color(0, 255, 0, 1))
	self.set_theme(th)


