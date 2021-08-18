module clip

import math.util as math
import os
import strings

pub struct Subcommand {
	before string
pub:
	name        string       [required]
	short       string
	help        string
	version     string
	author      string
	about       string
	usages      []string
	flags       []Flag
	options     []Opt
	subcommands []Subcommand
	footer      string
}

fn (cmd Subcommand) print(before string) {
	println(cmd.format(before, Colorizers{}, 'NO_COLOR' !in os.environ()))
}

// Prints out help message
//
// Should be called only from App
fn (cmd Subcommand) format(before string, colorizers Colorizers, colorized bool) string {
	mut bldr := strings.new_builder(256)

	if !is_empty(cmd.name) || !is_empty(cmd.version) {
		bldr.writeln('$before $cmd.version')
	}

	if !is_empty(cmd.author) {
		bldr.writeln(cmd.author)
	}

	if !is_empty(cmd.about) {
		bldr.writeln(cmd.about)
	}

	bldr.writeln('')

	if !is_empty(cmd.usages) {
		bldr.writeln(colorize(colorized, colorizers.category, 'Usage:'))
		for usage in cmd.usages {
			bldr.write_string(indent)
			bldr.write_string(before)
			bldr.write_string(' ')
			bldr.writeln(usage)
		}
	}

	if !is_empty(cmd.flags) {
		bldr.writeln('')
		cmd.flags.format(mut bldr, colorized, colorizers)
	}

	if !is_empty(cmd.options) {
		bldr.writeln('')
		cmd.options.format(mut bldr, colorized, colorizers)
	}

	if !is_empty(cmd.subcommands) {
		bldr.writeln('')
		cmd.subcommands.format(mut bldr, colorized, colorizers)
	}

	if !is_empty(cmd.footer) {
		bldr.writeln('')
		bldr.writeln(cmd.footer)
	}

	return bldr.str()
}

fn (subcommands []Subcommand) format(mut bldr strings.Builder, colorized bool, colorizers Colorizers) {
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
			if !is_empty(subcmd.short) {
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
