module clip

import term

pub struct Colorizers {
pub:
	category fn (string) string = term.yellow
	keyword  fn (string) string = term.green
}

fn colorize(colorized bool, cfn fn (string) string, text string) string {
	if colorized {
		return cfn(text)
	}
	return text
}