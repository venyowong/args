module args

fn test_add_arg() {
	mut a := Args{}
	a.add_arg('action', 'a', 'desc')
	assert a.args['action'].name == 'action'
}

fn test_parse() {
	mut a := Args{}
	a.add_arg('action', 'a', 'desc')
	a.parse(['-a', 'xxx'])
	assert a.args['action'].value == 'xxx'
}

fn test_get() {
	mut a := Args{}
	a.add_arg('action', 'a', 'desc')
	assert a.get('action')?.name == 'action'
}

struct Params {
	pub mut:
		args Args
		action string [name: action; short_name: a; desc: description]
}

fn test_parse2() {
	p := args.parse[Params](['-a', 'xxx']) or {panic('args parse error')}
	assert p.action == 'xxx'
}