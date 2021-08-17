module clip

import math.util as math
import strings

pub struct Flag {
pub:
	name          string [required]
	short         string
	help          string
	default_value bool
}

fn (flags []Flag) format(mut bldr strings.Builder, colorized bool, colorizers Colorizers, indent string, help_offset int) {
	bldr.writeln(colorize(colorized, colorizers.category, 'Flags:'))

	mut max_name_len := 0
	mut max_short_len := 0
	for flag in flags {
		max_name_len = math.imax(max_name_len, flag.name.len)
		max_short_len = math.imax(max_short_len, flag.short.len)
	}

	for flag in flags {
		bldr.write_string(indent)
		if max_short_len != 0 {
			if !isempty(flag.short) {
				bldr.write_string(' '.repeat(max_short_len - flag.short.len))
				bldr.write_string(colorize(colorized, colorizers.keyword, '-$flag.short'))
				bldr.write_string(', ')
			} else {
				bldr.write_string(' '.repeat(max_short_len + 3))
			}
		}
		bldr.write_string(colorize(colorized, colorizers.keyword, '--$flag.name'))
		bldr.write_string(' '.repeat(max_name_len - flag.name.len + help_offset))
		bldr.writeln(flag.help)
	}
}