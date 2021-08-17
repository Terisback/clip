module clip

import math.util as math
import os
import strings

pub fn (a App) format(colorized bool) string {
	mut bldr := strings.new_builder(256)

	if !isempty(a.name) || !isempty(a.version) {
		bldr.writeln('$a.name $a.version')
	}

	if !isempty(a.author) {
		bldr.writeln(a.author)
	}

	if isempty(a.about) {
		bldr.writeln(a.about)
	}

	bldr.writeln('')

	// vfmt adding dot before constants so it placed there
	// TODO: When vfmt will be fixed, move this variable to consts
	help_offset := 2
	indent := '    '
	app_name := if isempty(a.app_name) { os.file_name(os.executable()) } else { a.app_name }

	bldr.writeln(colorize(colorized, a.colorizers.category, 'Usage:'))
	if a.usages.len == 0 {
		bldr.write_string(indent)
		bldr.write_string(app_name)

		if !isempty(a.flags) {
			bldr.write_string(' [FLAGS]')
		}

		if !isempty(a.options) {
			bldr.write_string(' [OPTIONS]')
		}

		if !isempty(a.subcommands) {
			bldr.write_string(' [SUBCOMMAND]')
		}

		bldr.writeln(' INPUT...')
	} else {
		for usage in a.usages {
			bldr.write_string(indent)
			bldr.write_string(app_name + ' ')
			bldr.writeln(usage)
		}
	}

	if !isempty(a.flags) {
		bldr.writeln('')
		bldr.writeln(colorize(colorized, a.colorizers.category, 'Flags:'))

		mut max_name_len := 0
		mut max_short_len := 0
		for flag in a.flags {
			max_name_len = math.imax(max_name_len, flag.name.len)
			max_short_len = math.imax(max_short_len, flag.short.len)
		}

		for flag in a.flags {
			bldr.write_string(indent)
			if max_short_len != 0 {
				if !isempty(flag.short) {
					bldr.write_string(' '.repeat(max_short_len - flag.short.len))
					bldr.write_string(colorize(colorized, a.colorizers.keyword, '-$flag.short'))
					bldr.write_string(', ')
				} else {
					bldr.write_string(' '.repeat(max_short_len + 3))
				}
			}
			bldr.write_string(colorize(colorized, a.colorizers.keyword, '--$flag.name'))
			bldr.write_string(' '.repeat(max_name_len - flag.name.len + help_offset))
			bldr.writeln(flag.help)
		}
	}

	if !isempty(a.options) {
		bldr.writeln('')
		bldr.writeln(colorize(colorized, a.colorizers.category, 'Options:'))

		mut max_paraname_len := 0
		mut max_short_len := 0
		for opt in a.options {
			max_paraname_len = math.imax(max_paraname_len, opt.name.len + opt.param.len)
			max_short_len = math.imax(max_short_len, opt.short.len)
		}

		for opt in a.options {
			bldr.write_string(indent)
			if max_short_len != 0 {
				if !isempty(opt.short) {
					bldr.write_string(' '.repeat(max_short_len - opt.short.len))
					bldr.write_string(colorize(colorized, a.colorizers.keyword, '-$opt.short'))
					bldr.write_string(', ')
				} else {
					bldr.write_string(' '.repeat(max_short_len + 3))
				}
			}
			paraname_len := opt.name.len + opt.param.len
			bldr.write_string(colorize(colorized, a.colorizers.keyword, '--$opt.name <$opt.param>'))
			bldr.write_string(' '.repeat(max_paraname_len - paraname_len + help_offset))
			bldr.writeln(opt.help)
		}
	}

	if !isempty(a.subcommands) {
		bldr.writeln('')
		bldr.writeln(colorize(colorized, a.colorizers.category, 'Subcommands:'))

		mut max_name_len := 0
		mut max_short_len := 0
		for subcmd in a.subcommands {
			max_name_len = math.imax(max_name_len, subcmd.name.len)
			max_short_len = math.imax(max_short_len, subcmd.short.len)
		}

		for subcmd in a.subcommands {
			bldr.write_string(indent)
			if max_short_len != 0 {
				if !isempty(subcmd.short) {
					bldr.write_string(' '.repeat(max_short_len - subcmd.short.len))
					bldr.write_string(colorize(colorized, a.colorizers.keyword, subcmd.short))
					bldr.write_string(', ')
				} else {
					bldr.write_string(' '.repeat(max_short_len + 2))
				}
			}
			bldr.write_string(colorize(colorized, a.colorizers.keyword, subcmd.name))
			bldr.write_string(' '.repeat(max_name_len - subcmd.name.len + help_offset))
			bldr.writeln(subcmd.help)
		}
	}

	if !isempty(a.footer) {
		bldr.writeln('')
		bldr.writeln(a.footer)
	}

	return bldr.str()
}

pub fn (cmd Subcommand) format(colorized bool) string {
	mut bldr := strings.new_builder(256)

	return bldr.str()
}
