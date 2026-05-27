class_name gameLog

extends RichTextLabel

var maxLen : int = 100

func addToLog(origin : String, message : String):
	if get_paragraph_count() < maxLen:
		append_text("%s: %s \n" % [origin, message])
	else:
		remove_paragraph(0, true)
		append_text("%s: %s \n" % [origin, message])
