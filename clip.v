module clip

import strings
import math.util as math

pub fn new_app()

pub struct App {
pub mut:
	name     string [required]
	bin_name string [required]

	version     string
	author      string = 'Unknown'
	header      string
	flags       []Flag
	args        []Arg
	subcommands []Subcommand
	footer      string
}

pub fn (a App) str() string {
	mut str_builder := strings.new_builder(20)
	str_builder.writeln('$a.name $a.version')
	str_builder.writeln('$a.author')
	str_builder.writeln('$a.header\n')

	str_builder.writeln('Usage:')
	str_builder.writeln('\t$a.bin_name [FLAGS] [ARGS] [SUBCOMMAND]\n')

	str_builder.writeln('Flags:')
	mut max_flag_len := 0
	for flag in a.flags {
		max_flag_len = math.imax(max_flag_len, flag.name.len + 2 +
			if flag.short_name.len != 0 { flag.short_name.len + 3 } else { 0 })
	}
	for flag in a.flags {
		str_builder.write_b(byte(`\t`))
		if flag.short_name.len != 0 {
			str_builder.write_string('-$flag.short_name, ')
		}
		str_builder.write_string('--$flag.name')
		str_builder.write_string(' '.repeat(max_flag_len + 2 - (flag.name.len + 2 +
			if flag.short_name.len != 0 { flag.short_name.len + 3 } else { 0 })))
		str_builder.writeln('$flag.help')
	}

	return str_builder.str()
}

pub struct Subcommand {
pub mut:
	author      string = 'Unknown'
	header      string
	version     string
	name        string       [required]
	short_name  string
	args        []Arg
	flags       []Flag
	subcommands []Subcommand
	help        string
	footer      string
}

pub struct Flag {
pub mut:
	default_value bool
	name          string [required]
	short_name    string
	help          string
}

// Custom options like `--config <FILE>`
pub struct Arg {
pub mut:
	required   bool
	name       string [required]
	short_name string
	help       string
	multiple   bool
}
