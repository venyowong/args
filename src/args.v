module args

import v.reflection

pub struct Args {
	mut:
		args map[string]Arg
		short_args map[string]Arg
}

pub fn (mut a Args) add_arg(name string, short_name string, desc string) {
	arg := Arg{
		name: name,
		short_name: short_name,
		desc: desc
	}
	a.args[name] = arg
	if short_name != '' {
		a.short_args[short_name] = arg
	}
}

pub fn (a Args) show_help() {
	mut result := 'v run . [-h]\n'
	for _, arg in a.args {
		result += '  --${arg.name}/-${arg.short_name} ${arg.desc}\n'
	}
	println(result)
}

// example: a.parse(os.args[1..])
pub fn (mut a Args) parse(array []string) bool {
	mut arg := Arg{}
	for item in array {
		if item.starts_with('--') {
			key := item[2..]
			if key in a.args {
				arg = a.args[key]
			} else {
				println('${item} not supported')
				return false
			}
		} else if item.starts_with('-') {
			key := item[1..]
			if key in a.short_args {
				arg = a.short_args[key]
			} else {
				println('${item} not supported')
				return false
			}
		} else if arg.name != '' {
			arg.used = true
			arg.value = item
			a.args[arg.name] = arg
		}
	}
	if arg.name != '' {
		arg.used = true
		a.args[arg.name] = arg
	}

	return true
}

pub fn (a Args) get(key string) ?Arg {
	if key in a.args {
		return a.args[key]
	} else {
		return none
	}
}

fn (mut a Args) add_struct_field(f reflection.StructField) {
	mut name := ''
	mut short_name := ''
	mut desc := ''
	for attr in f.attrs {
		if attr.starts_with('name=') {
			name = attr[5..]
		}
		if attr.starts_with('short_name=') {
			short_name = attr[11..]
		}
		if attr.starts_with('desc=') {
			desc = attr[5..]
		}
	}
	if name != '' {
		a.add_arg(name, short_name, desc)
	}
}

/*
pub struct Params {
	pub mut:
		args args.Args
		action string [name: action; short_name: a; desc: description]
}

example: 
p := args.parse[Params](os.args[1..]) or {panic('args parse error')}
if p.action == 'xxx' {
	// do something
} else {
	p.args.show_help()
}
*/
pub fn parse[T](array []string) ?T {
	mut result := T{}
	t := reflection.type_of(result)
	s := t.sym.info as reflection.Struct

	mut a := Args{}
	for field in s.fields {
		a.add_struct_field(field)
	}

	if !a.parse(array) {
		return none
	}

	$for field in T.fields {
		$if field.name == 'args' {
			result.args = a
		} $else {
			if field.name in a.args {
				arg := a.args[field.name]
				$if field.typ is bool {
					result.$(field.name) = arg.used
				} $else {
					result.$(field.name) = arg.value
				}
			}
		}
	}
	return result
}