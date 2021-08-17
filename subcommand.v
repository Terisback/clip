module clip 

import math.util as math
import strings

pub struct Subcommand {
pub:
	name        string       [required]
	short       string
	help        string
	version     string
	author      string
	about       string
	flags       []Flag
	options     []Opt
	subcommands []Subcommand
	footer      string
}

// Prints out help message
//
// Should be called only from App
fn (cmd Subcommand) format(colorized bool) string {
	mut bldr := strings.new_builder(256)

	return bldr.str()
}

fn (subcommands []Subcommand) format(mut bldr strings.Builder, colorized bool, colorizers Colorizers, indent string, help_offset int) {
	bldr.writeln(colorize(colorized, colorizers.category, 'Subcommands:'))

	mut max_name_len := 0
	mut max_short_len := 0
	for subcmd in subcommands {
		max_name_len = math.imax(max_name_len, subcmd.name.len)
		max_short_len = math.imax(max_short_len, subcmd.short.len)
	}

	for subcmd in subcommands {
		bldr.write_string(indent)
		if max_short_len != 0 {
			if !isempty(subcmd.short) {
				bldr.write_string(' '.repeat(max_short_len - subcmd.short.len))
				bldr.write_string(colorize(colorized, colorizers.keyword, subcmd.short))
				bldr.write_string(', ')
			} else {
				bldr.write_string(' '.repeat(max_short_len + 2))
			}
		}
		bldr.write_string(colorize(colorized, colorizers.keyword, subcmd.name))
		bldr.write_string(' '.repeat(max_name_len - subcmd.name.len + help_offset))
		bldr.writeln(subcmd.help)
	}
}