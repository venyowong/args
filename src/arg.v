module args

pub struct Arg {
	pub:
		name string
		short_name string
		desc string
	pub mut:
		value string
		used bool
}