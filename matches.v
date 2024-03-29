module clip

pub struct Matches {
	before string
mut:
	argument       string
	flags          map[string]bool
	opts           map[string][]string
	matched_subcmd string
	subcommand     &Matches = voidptr(0)
}

fn (m Matches) is_empty() bool {
	return is_empty(m.argument) && is_empty(m.flags) && is_empty(m.opts) && is_empty(m.matched_subcmd)
}

pub fn (m Matches) argument() string {
	return m.argument
}

pub fn (m Matches) flag(name string) ?bool {
	if name in m.flags {
		return m.flags[name]
	}
	return error('does not exist')
}

pub fn (m Matches) option(name string) ?[]string {
	if name in m.opts {
		return m.opts[name]
	}
	return error('does not exist')
}

pub fn (m Matches) subcommand() ?(string, Matches) {
	if m.matched_subcmd != '' {
		return m.matched_subcmd, *m.subcommand
	}
	return error('does not matched any subcommand')
}
