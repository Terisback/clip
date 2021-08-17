module clip

import math.util as math
import os
import strings
import term
import v.vmod

// Creates new App
pub fn new(name string) App {
	return App{
		name: name
	}
}

// Creates new cli app with name, version, author and about with values of v.mod file
//
// Panics if pseudo variable @VMOD_FILE is not present or incorrect
pub fn vmod() App {
	mod := vmod.decode(@VMOD_FILE) or { panic(err.msg) }
	return App{
		name: mod.name
		version: mod.version
		author: mod.author
		about: mod.description
	}
}


pub fn (app App) vmod() App {
	mod := vmod.decode(@VMOD_FILE) or { panic(err.msg) }
	return App{
		...app
		name: mod.name
		version: mod.version
		author: mod.author
		about: mod.description
	}
}

pub struct App {
pub:
	name        string       [required]
	version     string
	author      string
	about       string
	usages      []string
	flags       []Flag
	options     []Opt
	subcommands []Subcommand
	footer      string
	// Binary name used in `Usage: <bin_name> [FLAGS] [OPTIONS] [SUBCOMMAND]` example
	//
	// Defaults to executable name or `v.mod` field `name` on call of `app.vmod()`
	app_name string

	category_colorizer fn (string) string = term.yellow
	keyword_colorizer  fn (string) string = term.green
}

pub fn (a App) format(colorized bool) string {
	mut bldr := strings.new_builder(256)

	if isempty(a.name) || isempty(a.version) {
		bldr.writeln('$a.name $a.version')
	}

	if isempty(a.author) {
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

	bldr.writeln(colorize(colorized, a.category_colorizer, 'Usage:'))
	if a.usages.len == 0 {
		bldr.write_string(indent)
		bldr.writeln('$app_name [FLAGS] [OPTIONS] [SUBCOMMAND]')
	} else {
		for usage in a.usages {
			bldr.write_string(indent)
			bldr.write_string(app_name + " ")
			bldr.writeln(usage)
		}
	}

	if !isempty(a.flags) {
		bldr.writeln('')
		bldr.writeln(colorize(colorized, a.category_colorizer, 'Flags:'))

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
					bldr.write_string(colorize(colorized, a.keyword_colorizer, '-$flag.short'))
					bldr.write_string(', ')
				} else {
					bldr.write_string(' '.repeat(max_short_len + 3))
				}
			}
			bldr.write_string(colorize(colorized, a.keyword_colorizer, '--$flag.name'))
			bldr.write_string(' '.repeat(max_name_len - flag.name.len + help_offset))
			bldr.writeln(flag.help)
		}
	}

	if !isempty(a.options) {
		bldr.writeln('')
		bldr.writeln(colorize(colorized, a.category_colorizer, 'Options:'))

		mut max_paraname_len := 0
		mut max_short_len := 0
		for opt in a.options {
			max_paraname_len = math.imax(max_paraname_len, opt.name.len + opt.param.len)
			max_short_len = math.imax(max_short_len, opt.short.len)
		}

		for opt in a.options {
			bldr.write_string(indent)
			if max_short_len != 0  {
				if !isempty(opt.short) {
					bldr.write_string(' '.repeat(max_short_len - opt.short.len))
					bldr.write_string(colorize(colorized, a.keyword_colorizer, '-$opt.short'))
					bldr.write_string(', ')
				} else {
					bldr.write_string(' '.repeat(max_short_len + 3))
				}
			}
			paraname_len := opt.name.len + opt.param.len
			bldr.write_string(colorize(colorized, a.keyword_colorizer, '--$opt.name <$opt.param>'))
			bldr.write_string(' '.repeat(max_paraname_len - paraname_len + help_offset))
			bldr.writeln(opt.help)
		}
	}

	if !isempty(a.subcommands) {
		bldr.writeln('')
		bldr.writeln(colorize(colorized, a.category_colorizer, 'Subcommands:'))

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
					bldr.write_string(colorize(colorized, a.keyword_colorizer, subcmd.short))
					bldr.write_string(', ')
				} else {
					bldr.write_string(' '.repeat(max_short_len + 2))
				}
			}
			bldr.write_string(colorize(colorized, a.keyword_colorizer, subcmd.name))
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

pub fn (a App) str() string {
	return a.format('NO_COLOR' !in os.environ())
}

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

pub fn (cmd Subcommand) format(colorized bool) string {
	mut bldr := strings.new_builder(256)


	return bldr.str()
}

pub fn (cmd Subcommand) str() string {
	return cmd.format('NO_COLOR' !in os.environ())
} 

pub struct Flag {
pub:
	name          string [required]
	short         string
	help          string
	default_value bool
}

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

fn colorize(colorized bool, cfn fn (string) string, text string) string {
	if colorized {
		return cfn(text)
	}
	return text
}

fn append<T>(a []T, b ...T) []T {
	mut m := []T{cap: a.len + b.len}

	for elem in a {
		m << elem
	}

	for elem in b {
		m << elem
	}

	return m
}

fn isempty<T>(text T) bool {
	return text.len == 0
}