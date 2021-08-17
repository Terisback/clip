module clip

pub struct Matches {
	argument    string
	flags       map[string]bool
	opts        map[string]string
	subcommands map[string]Matches
}

pub fn (m Matches) flag(flag_name string) bool {
	return flag_name in m.flags
}