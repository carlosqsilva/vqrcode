import arrays

pub struct Element {
	name string
mut:
	attr  map[string]string
	child []Element
}

pub fn new_element(name string) Element {
	return Element{
		name: name
	}
}

pub fn (mut el Element) set_attribute(attr string, value string) {
	el.attr[attr] = '"$value"'
}

pub fn (mut el Element) append_child(child Element) {
	el.child << child
}

pub fn (mut el Element) attr() string {
	return arrays.fold(el.attr.keys(), '', fn [el] (acc string, key string) string {
		return '$acc $key=${el.attr[key]}'
	})
}

pub fn (el Element) child() string {
	return arrays.fold(el.child, '', fn (acc string, child Element) string {
		return '$acc$child'
	})
}

pub fn (mut el Element) str() string {
	return '<$el.name$el.attr()>$el.child()</$el.name>'
}
