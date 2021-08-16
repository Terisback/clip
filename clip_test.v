module clip

fn test_app_constructor() {
	println(App{
		name: 'Some cool app name'
		bin_name: 'cool_app_name'
		version: '1.0.0'
		header: 'Description of the app'
		author: "It's me Mario!"
		args: [
			Arg{
				required: true
				name: 'verbose'
				short_name: 'v'
				help: 'Choose verbosity level: 0, 1, 2'
			},
			Arg{
				required: true
				name: 'target'
				help: 'Choose build target'
			},
		]
		flags: [
			Flag{
				name: 'help'
				short_name: 'h'
				help: 'Show this message'
			},
			Flag{
				name: 'version'
				short_name: 'V'
				help: 'Prints version information'
			},
		]
		subcommands: [
			Subcommand{
				header: 'Additional info about subcommand'
				version: '0.1.0'
				name: 'build'
				short_name: 'b'
				flags: [
					Flag{
						name: 'help'
						short_name: 'h'
						help: 'Show this message'
					},
					Flag{
						name: 'version'
						short_name: 'V'
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
