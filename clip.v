module clip

import os
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
	return a.get_matches_from(os.args.join(' '))
}

pub fn (a App) get_matches_from(args string) ?Matches {
	return a.parse(args)
}

pub fn (a App) str() string {
	return a.format('NO_COLOR' !in os.environ())
}
