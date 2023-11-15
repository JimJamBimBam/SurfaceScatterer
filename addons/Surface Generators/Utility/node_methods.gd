class_name NodeMethods extends Object
## Static methods to be used with Nodes and anything that inherits from Nodes class.

## Searches children of "node" for the first instance of Type, "type."
## Will only go as far as children, no grandchildren, etc.
static func get_first_instance_of_type_in_children(type: Variant, node: Node, include_internal: bool = false) -> Node:
	var child_to_return: Node
	for child in node.get_children(include_internal):
		# Is this the nodes we are looking for?
		if is_instance_of(child, type):
			# Yes. Break out of the loop as we have found what we need.
			child_to_return = child
			break
		else:
			# No. The child with type does not exist.
			# Return null.
			child_to_return = null
	return child_to_return


## Returns the first instance of Type, "type" in the children of "node".
## Will search through all children, grandchildren etc. for the first instance.
static func get_first_instance_of_type_in(type: Variant, node: Node, include_internal: bool = false) -> Node:
	if node == null:
		return null
	
	var return_node: Node
	for child in node.get_children(include_internal):
		# Is this child the one we are looking for?
		if is_instance_of(child, type):
			# Yes. Reuturn it straight away.
			return child
		
		# If the child is not an instance of the type,
		# Can we keep looking down the list of childtren?
		if child.get_child_count(include_internal) > 0:
			# Yes. Continue down the list of children
			return_node = get_first_instance_of_type_in(type, child, include_internal)
		else:
			# No. We have reached the end of the child list and no node of type has been found.
			# Return null.
			return_node = null
	return return_node


## Returns an Array of Nodes that contain every child, grand-child, etc.
## Searches only through the input "node" for children.
static func get_all_children_in(node: Node, include_internal: bool = false) -> Array[Variant]:
	# Input node is null
	if node == null:
		return []
	
	var nodes : Array[Variant] = []
	for child in node.get_children(include_internal):
		if child.get_child_count(include_internal) > 0:
			# Append the child that has children to the end of the array.
			nodes.append(child)
			# Append all of it's children as well
			nodes.append_array(get_all_children_in(child, include_internal))
		else:
			# Append the child that has no children to the end of the array
			nodes.append(child)
	return nodes
	
## Returns an Array of Nodes that contains every child, grand-child, etc of Type, "type".
## Searches only through the input "node" for children of Type, "type".
static func get_all_children_of_type_in(type: Variant, node: Node, include_internal: bool = false) -> Array[Node]:
	# Input node is null
	if node == null:
		return []
	
	var nodes_of_type: Array[Node] = []
	for child in node.get_children(include_internal):
		if child.get_child_count(include_internal) > 0:
			# Append child only if they are of the Type, "type"
			if is_instance_of(child, type):
				nodes_of_type.append(child)
			# Append all of "child" children by recursion.
			nodes_of_type.append_array(get_all_children_of_type_in(type, child, include_internal))
		else:
			if is_instance_of(child, type):
				nodes_of_type.append(child)
	return nodes_of_type
			
