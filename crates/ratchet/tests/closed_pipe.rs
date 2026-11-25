//! Standard output that cannot be written.
//!
//! A reader that is gone (`ratchet --help | true`) is an ordinary end of a command line: the
//! binary ends without a panic, writes nothing on standard error and keeps the exit status of
//! the command. Any other failure to write is named on standard error and is exit status 1.

use std::process::Stdio;

/// What `ratchet` answers when the reader of its standard output is gone before it starts: the
/// exit status and standard error.
fn with_reader_gone(args: &[&str]) -> (Option<i32>, String) {
    let (reader, writer) = std::io::pipe().expect("a pipe");
    drop(reader);
    let output = crate::ratchet()
        .args(args)
        .stdout(writer)
        .stderr(Stdio::piped())
        .output()
        .expect("the ratchet binary starts");
    (
        output.status.code(),
        String::from_utf8(output.stderr).expect("standard error is UTF-8"),
    )
}

#[test]
fn reader_gone_is_no_panic() {
    for args in [
        &["--help"][..],
        &["--version"],
        &["completions", "bash"],
        &["doctor", "--help"],
    ] {
        assert_eq!(
            with_reader_gone(args),
            (Some(0), String::new()),
            "the exit status and standard error of `ratchet {}` with its reader gone",
            args.join(" ")
        );
    }
}

/// An answer that writes nothing on standard output keeps its status and its line. `doctor` is a
/// command no story of 0.1.0 builds.
#[test]
fn reader_gone_keeps_the_status_of_the_command() {
    assert_eq!(
        with_reader_gone(&["doctor"]),
        (Some(1), "cli_handler_unavailable\n".to_owned())
    );
}

/// A device without space is no reader that left: the failure is named and the status is 1.
#[cfg(target_os = "linux")]
#[test]
fn full_device_is_named() {
    let full = std::fs::OpenOptions::new()
        .write(true)
        .open("/dev/full")
        .expect("/dev/full opens for writing");
    let output = crate::ratchet()
        .arg("--help")
        .stdout(full)
        .stderr(Stdio::piped())
        .output()
        .expect("the ratchet binary starts");
    let stderr = String::from_utf8(output.stderr).expect("standard error is UTF-8");
    assert_eq!(output.status.code(), Some(1), "standard error:\n{stderr}");
    assert!(
        stderr.starts_with("ratchet: standard output: ") && stderr.lines().count() == 1,
        "standard error names the failure in one line:\n{stderr}"
    );
}
