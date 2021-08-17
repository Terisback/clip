module clip

// Custom options like `--config <FILE>`
pub struct Opt {
pub:
	name     string [required]
	short    string
	param    string [required]
	help     string
	required bool
	multiple bool
}