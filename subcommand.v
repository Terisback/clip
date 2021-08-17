module clip 

import os

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

pub fn (cmd Subcommand) str() string {
	return cmd.format('NO_COLOR' !in os.environ())
}