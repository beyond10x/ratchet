//! The `ratchet` command line.
//!
//! The parser, the help text and the process adapter come from the generated package
//! `ratchet-cli-contract` (`ess generate cli` over `spec/cli.yaml`). This crate supplies what
//! the generated code leaves open: the handler behind each command, in `commands`, the answer
//! to `--version`, and the writing of the two streams.

mod commands;

use std::ffi::OsString;
use std::io::{ErrorKind, Write};

/// The line `ratchet --version` prints: the binary and the version of the workspace.
const VERSION_LINE: &str = concat!("ratchet ", env!("CARGO_PKG_VERSION"), "\n");

fn main() {
    let args: Vec<OsString> = std::env::args_os().collect();
    // The generated parser declares no version, so `--version` never reaches it. It is a
    // version request only as the whole command line; beside another argument the parser
    // refuses it like any flag it does not know.
    if args.len() == 2 && args[1] == "--version" {
        std::process::exit(emit(VERSION_LINE, "", 0));
    }
    let output = cli_contract::run(
        args,
        &mut cli_contract::OsSources,
        &mut commands::Commands,
        None,
    );
    std::process::exit(emit(&output.stdout, &output.stderr, output.exit_code));
}

/// Writes the two streams and returns the exit status of the process.
///
/// A reader of standard output that is gone (`ratchet --help | true`) is an ordinary end of a
/// command line: nothing more is said, and the status stays the command's own, so a gate that
/// failed still exits 1 and one that passed still exits 0 under `set -o pipefail`. Any other
/// failure to write standard output is named on standard error, and the status is 1 when the
/// command's own was 0. A failure to write standard error has no stream left to be named on.
fn emit(stdout: &str, stderr: &str, exit_code: i32) -> i32 {
    let mut out = std::io::stdout().lock();
    let written = out.write_all(stdout.as_bytes()).and_then(|()| out.flush());
    let mut err = std::io::stderr().lock();
    let _ = err.write_all(stderr.as_bytes());
    match written {
        Ok(()) => exit_code,
        Err(error) if error.kind() == ErrorKind::BrokenPipe => exit_code,
        Err(error) => {
            let _ = writeln!(err, "ratchet: standard output: {error}");
            if exit_code == 0 { 1 } else { exit_code }
        }
    }
}
