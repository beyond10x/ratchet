//! The integration tests of the `ratchet` binary: the one test binary of this crate.
//!
//! Each module tests one command file of `src/commands/` and has its own file here, so the story
//! that builds a command edits that command's test file and no other. `commands` holds the
//! commands that share one answer.

mod assess;
mod commands;
mod evaluate;
mod reference_adopt;
mod validate;

use std::process::{Command, Stdio};

/// What one run of the binary answered.
pub struct Answer {
    /// The exit status, or none when a signal ended the process.
    pub status: Option<i32>,
    /// Standard output as text.
    pub stdout: String,
    /// Standard error as text.
    pub stderr: String,
}

/// The `ratchet` binary cargo built for this test run, with no standard input.
pub fn ratchet() -> Command {
    let mut command = Command::new(env!("CARGO_BIN_EXE_ratchet"));
    command.stdin(Stdio::null());
    command
}

/// Runs `ratchet` with these arguments in its default output mode.
pub fn run(args: &[&str]) -> Answer {
    let output = ratchet()
        .args(args)
        .output()
        .expect("the ratchet binary starts");
    Answer {
        status: output.status.code(),
        stdout: String::from_utf8(output.stdout).expect("standard output is UTF-8"),
        stderr: String::from_utf8(output.stderr).expect("standard error is UTF-8"),
    }
}

/// The answer of a command that has no handler yet: exit status 1, nothing on standard output,
/// the line `cli_handler_unavailable` on standard error.
pub fn assert_unavailable(args: &[&str]) {
    let answer = run(args);
    assert_eq!(
        (
            answer.status,
            answer.stdout.as_str(),
            answer.stderr.as_str()
        ),
        (Some(1), "", "cli_handler_unavailable\n"),
        "the answer of `ratchet {}`",
        args.join(" ")
    );
}
