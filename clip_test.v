module clip

import v.vmod

fn test_new() {
	app := new('Clap CLI')
	assert app.name == 'Clap CLI'
}

fn test_vmod() {
	app := new('Clap CLI').vmod(@VMOD_FILE)
	mod := vmod.decode(@VMOD_FILE) or { panic(err.msg) }
	assert app.name == mod.name
	assert app.version == mod.version
	assert app.author == mod.author
	assert app.about == mod.description
}

fn test_app_constructor() {
	app := App{
		name: 'coolap'
		version: '1.0.0'
		about: 'Description of the app'
		author: 'Mario Pipelover <mpipelover@example.com>'
		options: [
			Opt{
				required: true
				name: 'verbose'
				short: 'v'
				param: 'level'
				help: 'Choose verbosity level: 0, 1, 2'
			},
			Opt{
				required: true
				name: 'target'
				param: 'os'
				help: 'Choose build target'
			},
		]
		flags: [
			Flag{
				name: 'version'
				short: 'V'
				help: 'Prints version information'
			},
		]
		subcommands: [
			Subcommand{
				about: 'Additional info about subcommand'
				version: '0.1.0'
				name: 'build'
				short: 'b'
				flags: [
					Flag{
						name: 'help'
						short: 'h'
						help: 'Show this message'
					},
					Flag{
						name: 'version'
						short: 'V'
						help: 'Prints version information'
					},
				]
				help: 'Help message for upper command'
				footer: 'Some usage examples'
			},
		]
		footer: 'Some cli app usage examples'
	}
	// println(app)
}

fn test_parse() ? {
	app := App{
		name: 'coolap'
		version: '1.0.0'
		about: 'Description of the app'
		author: 'Mario Pipelover <mpipelover@example.com>'
		flags: [
			Flag{
				name: 'debug'
				help: 'Enable debug'
			},
		]
		options: [
			Opt{
				required: true
				name: 'verbose'
				short: 'v'
				param: 'level'
				help: 'Choose verbosity level: 0, 1, 2'
			},
		]
		subcommands: [
			Subcommand{
				name: 'some'
				subcommands: [
					Subcommand{
						name: 'fome'
					},
				]
			},
		]
	}

	m := app.parse(['clip', '-v=4', '--debug', 'some', 'fome', 'arguemnt']) ?

	println(m)

	println(m.flag('debug') ?)

	println(m.option('verbose') ?)

	println(m.option('verbose') ?)

	subcmd, matches := m.subcommand() ?
	println(matches)
}

fn test_string_array_iterator() {
	mut array := StringArrayIterator{
		array: ['Hello', 'from', 'other', 'world', '!']
	}

	for str in array {
		println('$str, $array.peek(), $array.peek()')
	}
}
