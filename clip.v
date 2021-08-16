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

// Overrides name, version, author and about with values of v.mod file
//
// Panics if pseudo variable @VMOD_FILE is not present or incorrect
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

pub fn (app App) version(version string) App {
	return App{
		...app
		version: version
	}
}

pub fn (app App) author(author string) App {
	return App{
		...app
		author: author
	}
}

pub fn (app App) about(about string) App {
	return App{
		...app
		about: about
	}
}

pub fn (app App) flag(flag ...Flag) App {
	return App{
		...app
		flags: append(app.flags, ...flag)
	}
}

pub fn (app App) option(option ...Opt) App {
	return App{
		...app
		options: append(app.options, ...option)
	}
}

pub fn (app App) subcommand(subcommand ...Subcommand) App {
	return App{
		...app
		subcommands: append(app.subcommands, ...subcommand)
	}
}

pub fn (app App) footer(footer string) App {
	return App{
		...app
		footer: footer
	}
}

pub fn (app App) app_name(app_name string) App {
	return App{
		...app
		app_name: app_name
	}
}

pub fn (app App) set_category_colorizer(cfn fn (string) string) App {
	return App{
		...app
		category_colorizer: cfn
	}
}

pub fn (app App) set_keyword_colorizer(cfn fn (string) string) App {
	return App{
		...app
		keyword_colorizer: cfn
	}
}

pub struct App {
pub:
	name        string       [required]
	version     string
	author      string
	about       string
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

	if a.name.len != 0 || a.version.len != 0 {
		bldr.writeln('$a.name $a.version')
	}

	if a.author.len != 0 {
		bldr.writeln('$a.author')
	}

	if a.about.len != 0 {
		bldr.writeln('$a.about\n')
	}

	// vfmt adding dot before constants so it placed there
	help_offset := 2
	app_name := if a.app_name.len == 0 { os.file_name(os.executable()) } else { a.app_name }

	bldr.writeln(colorize(colorized, a.category_colorizer, 'Usage:'))
	bldr.write_string('\t')
	bldr.writeln('$app_name [FLAGS] [OPTIONS] [SUBCOMMAND]')

	bldr.writeln('')
	bldr.writeln(colorize(colorized, a.category_colorizer, 'Flags:'))

	mut max_name_len := 0
	mut max_short_len := 0
	for flag in a.flags {
		max_name_len = math.imax(max_name_len, flag.name.len)
		max_short_len = math.imax(max_short_len, flag.short.len)
	}

	for flag in a.flags {
		bldr.write_string('\t')
		if max_short_len != 0 {
			if flag.short.len != 0 {
				bldr.write_string(' '.repeat(max_short_len - flag.short.len))
				bldr.write_string(colorize(colorized, a.keyword_colorizer, '-$flag.short'))
				bldr.write_string(', ')
			} else {
				bldr.write_string(' '.repeat(max_short_len + 3))
			}
		}
		bldr.write_string(colorize(colorized, a.keyword_colorizer, '--$flag.name'))
		bldr.write_string(' '.repeat(max_name_len - flag.name.len + help_offset))
		bldr.writeln('$flag.help')
	}

	bldr.writeln('')
	bldr.writeln(colorize(colorized, a.category_colorizer, 'Options:'))

	max_name_len = 0
	max_short_len = 0
	for opt in a.options {
		max_name_len = math.imax(max_name_len, opt.name.len)
		max_short_len = math.imax(max_short_len, opt.short.len)
	}

	for opt in a.options {
		bldr.write_string('\t')
		if max_short_len != 0 {
			if opt.short.len != 0 {
				bldr.write_string(' '.repeat(max_short_len - opt.short.len))
				bldr.write_string(colorize(colorized, a.keyword_colorizer, '-$opt.short'))
				bldr.write_string(', ')
			} else {
				bldr.write_string(' '.repeat(max_short_len + 3))
			}
		}
		bldr.write_string(colorize(colorized, a.keyword_colorizer, '--$opt.name'))
		bldr.write_string(' '.repeat(max_name_len - opt.name.len + help_offset))
		bldr.writeln('$opt.help')
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
	mut m := []T{len: a.len + b.len}

	for elem in a {
		m << elem
	}

	for elem in b {
		m << elem
	}

	return m
}
