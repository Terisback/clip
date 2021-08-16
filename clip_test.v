module clip

fn test_app_constructor() {
	println(App{
		name: 'coolap'
		version: '1.0.0'
		about: 'Description of the app'
		author: 'Mario Pipelover <mpipelover@example.com>'
		options: [
			Opt{
				required: true
				name: 'verbose'
				short: 'v'
				help: 'Choose verbosity level: 0, 1, 2'
			},
			Opt{
				required: true
				name: 'target'
				help: 'Choose build target'
			},
		]
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
	})
}

fn test_append() {
	a := [1, 2, 3]
	b := [4, 5]
	c := append(a, ...b)
	assert [1, 2, 3, 4, 5] == c
}
