module main

import args
import os

pub struct Params {
	pub mut:
		args args.Args
		action string [name: action; short_name: a; desc: description]
}

fn main() {
	p := args.parse[Params](os.args[1..]) or {panic('args parse error')}
	if p.action == 'xxx' {
		// do something
	} else {
		p.args.show_help()
	}
}
