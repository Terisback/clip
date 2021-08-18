module clip

import os
import strings
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

// Internal method for adding help flag if it doesn't exist
//
// Because of bug, function that uses fill operator - `...`
// should be declared before struct declare
fn (a App) check_help_flag() App {
	mut help_flag_exists := false
	for flag in a.flags {
		if flag.short == 'h' || flag.name == 'help' {
			help_flag_exists = true
			break
		}
	}

	if !help_flag_exists {
		return App{
			...a
			flags: append([Flag{
				name: 'help'
				short: 'h'
				help: 'Prints this message'
			}], ...a.flags)
		}
	}

	return a
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

	colorizers Colorizers
}

pub fn (a App) get_matches() ?Matches {
	return a.get_matches_from(os.args)
}

pub fn (a App) get_matches_from(args []string) ?Matches {
	return a.parse(args)
}

pub fn (a App) help(colorized bool) string {
	return a.check_help_flag().format(colorized)
}

pub fn (a App) str() string {
	return a.check_help_flag().format('NO_COLOR' !in os.environ())
}

fn (a App) format(colorized bool) string {
	mut bldr := strings.new_builder(256)

	if !isempty(a.name) || !isempty(a.version) {
		bldr.writeln('$a.name $a.version')
	}

	if !isempty(a.author) {
		bldr.writeln(a.author)
	}

	if !isempty(a.about) {
		bldr.writeln(a.about)
	}

	bldr.writeln('')

	// vfmt adding dot before constants so it placed there
	// TODO: When vfmt will be fixed, move this variable to consts
	help_offset := 2
	indent := '    '
	app_name := if isempty(a.app_name) { os.file_name(os.executable()).split('.')[0] } else { a.app_name }

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
			bldr.write_string(app_name)
			bldr.write_string(' ')
			bldr.writeln(usage)
		}
	}

	if !isempty(a.flags) {
		bldr.writeln('')
		a.flags.format(mut bldr, colorized, a.colorizers, indent, help_offset)
	}

	if !isempty(a.options) {
		bldr.writeln('')
		a.options.format(mut bldr, colorized, a.colorizers, indent, help_offset)
	}

	if !isempty(a.subcommands) {
		bldr.writeln('')
		a.subcommands.format(mut bldr, colorized, a.colorizers, indent, help_offset)
	}

	if !isempty(a.footer) {
		bldr.writeln('')
		bldr.writeln(a.footer)
	}

	return bldr.str()
}

fn (app App) parse(args []string) ?Matches {
	mut arguments := args[1..] 
	mut matches := Matches{}

	for flag in app.flags {
		matches.flags[flag.name] = flag.default_value
	}

	mut required_opts := []string{}
	for option in app.options {
		if option.required {
			required_opts << option.name
		}
	}

	for index, arg in arguments {
		if app.parse_arg(mut matches, mut required_opts, arg) {
			continue
		}

		for subcmd in app.subcommands {
			if arg == subcmd.name && arg == subcmd.short {
				// Start subcmd parse
				// continue
			}
		}

		matches.argument = arguments[index..].join(' ')
		break
	}

	if !isempty(required_opts) {
		// TODO: Create error type
		return error('not all required options was provided, expected: `${required_opts.join('`, `')}`')
	}

	return matches
}

enum ArgType {
	short
	long
}

fn (app App) determine_arg(arg string) ([]string, ArgType) {
	if arg.starts_with('--') {
		return arg.trim_prefix('--').split('='), ArgType.long
	} else if arg.starts_with('-') {
		return arg.trim_prefix('-').split('='), ArgType.short
	}

	return []string{}, ArgType.long
}

fn (app App) parse_arg(mut matches Matches, mut required_opts []string, arg string) bool {
	parts, arg_type := app.determine_arg(arg)

	if parts.len != 0 && ((parts.len > 1 
		&& app.parse_option(mut matches, mut required_opts, parts, arg_type))
		|| app.parse_flag(mut matches, parts[0], arg_type)) {
		return true
	}

	return false
}

fn (app App) parse_flag(mut matches Matches, arg string, arg_type ArgType) bool {
	for flag in app.flags {
		name := match arg_type {
			.short { flag.short }
			.long { flag.name }
		}

		if arg == name {
			matches.flags[flag.name] = !flag.default_value
			return true
		}
	}

	return false
}

fn (app App) parse_option(mut matches Matches, mut required_opts []string, parts []string, arg_type ArgType) bool {
	for option in app.options {
		name := match arg_type {
			.short { option.short }
			.long { option.name }
		}

		if parts[0] == name {
			index := index_of(required_opts, option.name)

			if option.required && index != -1 {
				required_opts.delete(index)
			}

			if option.multiple {
				matches.opts[option.name] = parts[1..].join('=').split(',')
			} else {
				matches.opts[option.name] = [parts[1..].join('=')]
			}

			return true
		}
	}

	return false
}
