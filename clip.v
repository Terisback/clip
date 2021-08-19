module clip

import os
import strings
import v.vmod

const (
	help_offset = 2
	indent      = '    '
)

// Creates new App
pub fn new(name string) App {
	return App{
		name: name
	}
}

// Creates new cli app with name, version, author and about with values of v.mod file
pub fn vmod(mod_file string) App {
	mod := vmod.decode(mod_file) or { panic(err.msg) }
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
pub fn (app App) vmod(mod_file string) App {
	mod := vmod.decode(mod_file) or { panic(err.msg) }
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
fn check_help_flag(flags []Flag) []Flag {
	for flag in flags {
		if flag.name == 'help' || flag.short == 'h' {
			panic('you cannot redefine help flag')
		}
	}

	return append([Flag{
		name: 'help'
		short: 'h'
		help: 'Prints this message'
	}], ...flags)
}

fn (a App) help(colorized bool) string {
	return a.format(colorized)
}

fn (a App) print(before string) {
	a.print_help()
}

pub fn (a App) print_help() {
	println(a)
}

fn (app App) parse(args []string) ?Matches {
	a := App{
		...app
		flags: check_help_flag(app.flags)
	}

	mut matches := Matches{
		before: app.name
	}
	// Leave behind a binary or path what usually passed as before
	parse(mut matches, a, args[1..]) ?

	if matches.is_empty() {
		a.print(matches.before)
		exit(0)
	}

	return matches
}

pub struct App {
	before string
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
	colorizers  Colorizers
}

pub fn (a App) get_matches() ?Matches {
	return a.get_matches_from(os.args)
}

pub fn (a App) get_matches_from(args []string) ?Matches {
	return a.parse(args)
}

pub fn (a App) str() string {
	return a.help('NO_COLOR' !in os.environ())
}

fn (a App) format(colorized bool) string {
	mut bldr := strings.new_builder(256)

	if !is_empty(a.name) || !is_empty(a.version) {
		bldr.writeln('$a.name $a.version')
	}

	if !is_empty(a.author) {
		bldr.writeln(a.author)
	}

	if !is_empty(a.about) {
		bldr.writeln(a.about)
	}

	bldr.writeln('')

	bldr.writeln(colorize(colorized, a.colorizers.category, 'Usage:'))
	if a.usages.len == 0 {
		bldr.write_string(indent)
		bldr.write_string(a.name)

		if !is_empty(a.flags) {
			bldr.write_string(' [FLAGS]')
		}

		if !is_empty(a.options) {
			bldr.write_string(' [OPTIONS]')
		}

		if !is_empty(a.subcommands) {
			bldr.write_string(' [SUBCOMMAND]')
		}

		bldr.writeln(' INPUT...')
	} else {
		for usage in a.usages {
			bldr.write_string(indent)
			bldr.write_string(a.name)
			bldr.write_string(' ')
			bldr.writeln(usage)
		}
	}

	if !is_empty(a.flags) {
		bldr.writeln('')
		a.flags.format(mut bldr, colorized, a.colorizers)
	}

	if !is_empty(a.options) {
		bldr.writeln('')
		a.options.format(mut bldr, colorized, a.colorizers)
	}

	if !is_empty(a.subcommands) {
		bldr.writeln('')
		a.subcommands.format(mut bldr, colorized, a.colorizers)
	}

	if !is_empty(a.footer) {
		bldr.writeln('')
		bldr.writeln(a.footer)
	}

	return bldr.str()
}

interface Command {
	flags []Flag
	options []Opt
	subcommands []Subcommand
	print(before string)
}

fn parse(mut matches Matches, command Command, arguments []string) ? {
	if is_empty(arguments) {
		return
	}

	for flag in command.flags {
		matches.flags[flag.name] = flag.default_value
	}

	mut required_opts := []string{}
	for option in command.options {
		if option.required {
			required_opts << option.name
		}
	}

	for index, arg in arguments {
		if parse_arg(command, mut matches, mut required_opts, arg) ? {
			continue
		}

		if parse_subcommand(command.subcommands, mut matches, arg, arguments[index..]) ? {
			break
		}

		matches.argument = arguments[index..].join(' ')
		break
	}

	if !is_empty(required_opts) {
		// TODO: Create error type
		return error('not all required options was provided, expected: `${required_opts.join('`, `')}`')
	}

	return
}

enum ArgType {
	short
	long
}

fn determine_arg(arg string) ?([]string, ArgType) {
	if arg.starts_with('--') {
		return arg.trim_prefix('--').split('='), ArgType.long
	} else if arg.starts_with('-') {
		return arg.trim_prefix('-').split('='), ArgType.short
	}

	return error('')
}

fn parse_arg(command Command, mut matches Matches, mut required_opts []string, arg string) ?bool {
	parts, arg_type := determine_arg(arg) or { return false }

	if parts[0] == 'help' {
		command.print(matches.before)
		exit(0)
	}

	if parse_flag(command.flags, mut matches, parts[0], arg_type) || (parts.len > 1
		&& parse_option(command.options, mut matches, mut required_opts, parts, arg_type)) {
		return true
	}

	// TODO: Create error type
	return error('there is no such argument: `$arg`')
}

fn parse_flag(flags []Flag, mut matches Matches, arg string, arg_type ArgType) bool {
	for flag in flags {
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

fn parse_option(options []Opt, mut matches Matches, mut required_opts []string, parts []string, arg_type ArgType) bool {
	for option in options {
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

fn parse_subcommand(subcommands []Subcommand, mut matches Matches, arg string, rest []string) ?bool {
	for subcmd in subcommands {
		if arg in [subcmd.name, subcmd.short] {
			mut subcmd_matches := Matches{
				before: '$matches.before $subcmd.name'
			}
			parse(mut subcmd_matches, &subcmd, rest[1..]) ?
			matches.matched_subcmd = subcmd.name
			matches.subcommand = &subcmd_matches
			return true
		}
	}

	return false
}
