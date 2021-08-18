module clip

pub struct Matches {
mut:
	argument    string
	flags       map[string]bool
	opts        map[string][]string
	matched_subcmd string
	subcommand 	&Matches = voidptr(0)
}

pub fn (m Matches) flag(flag_name string) bool {
	return flag_name in m.flags
}
