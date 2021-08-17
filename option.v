module clip

import math.util as math
import strings

// Custom options like `--config <FILE>`
pub struct Opt {
pub:
	name     string [required]
	short    string
	param    string [required]
	help     string
	required bool
	multiple bool
}

fn (options []Opt) format(mut bldr strings.Builder, colorized bool, colorizers Colorizers, indent string, help_offset int) {
	bldr.writeln(colorize(colorized, colorizers.category, 'Options:'))

	mut max_paraname_len := 0
	mut max_short_len := 0
	for opt in options {
		max_paraname_len = math.imax(max_paraname_len, opt.name.len + opt.param.len)
		max_short_len = math.imax(max_short_len, opt.short.len)
	}

	for opt in options {
		bldr.write_string(indent)
		if max_short_len != 0 {
			if !isempty(opt.short) {
				bldr.write_string(' '.repeat(max_short_len - opt.short.len))
				bldr.write_string(colorize(colorized, colorizers.keyword, '-$opt.short'))
				bldr.write_string(', ')
			} else {
				bldr.write_string(' '.repeat(max_short_len + 3))
			}
		}
		paraname_len := opt.name.len + opt.param.len
		bldr.write_string(colorize(colorized, colorizers.keyword, '--$opt.name <$opt.param>'))
		bldr.write_string(' '.repeat(max_paraname_len - paraname_len + help_offset))
		bldr.writeln(opt.help)
	}
}
