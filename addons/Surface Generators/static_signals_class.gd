@tool
extends Object

class_name StaticSignalsClass

static func make_signal(p_obj: Object, p_signal_name: StringName):
#	if(p_obj.has_script_signal(p_signal_name)):
#		print_debug("We already have this signal made")
#		return Signal(null, "")
#	if(p_obj == null or p_signal_name.is_empty()):
#		return Signal(null, "")
	p_obj.add_user_signal(p_signal_name)
	return Signal(p_obj, p_signal_name)


static func make_signal_with_parameters(p_obj: Object, p_signal_name: StringName, arguements: Array) -> Signal:
	p_obj.add_user_signal(p_signal_name, arguements)
	return Signal(p_obj, p_signal_name)
