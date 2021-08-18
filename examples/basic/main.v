module main

import remimimimi.clip

const app = clip.App{
	name: 'spm'
	usages: [
		'install <package>',
	]
	flags: [
		clip.Flag{
			name: 'version'
			short: 'V'
			help: 'Prints version information'
		},
	]
	options: [
		clip.Opt{
			name: 'verbose'
			short: 'v'
			param: 'level'
			help: 'Choose verbosity level: debug, warn, info'
		},
	]
	subcommands: [
		clip.Subcommand{
			name: 'install'
			short: 'i'
			version: '0.1.0'
			author: 'Ivan Ivanov <iivanov@example.com>'
			about: 'Install specific module or modules from v.mod'
			help: 'Install specific module or modules from v.mod'
			usages: [
				'<package>',
			]
		},
	]
}

fn main() {
	app.vmod(@VMOD_FILE).get_matches() ?
}
