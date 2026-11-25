//! `ratchet --version`: the line a release is verified by.

#[test]
fn prints_the_workspace_version() {
    let answer = crate::run(&["--version"]);
    assert_eq!(
        (
            answer.status,
            answer.stdout.as_str(),
            answer.stderr.as_str()
        ),
        (
            Some(0),
            concat!("ratchet ", env!("CARGO_PKG_VERSION"), "\n"),
            ""
        ),
        "the answer of `ratchet --version`"
    );
}

/// `--version` is the whole command line or it is no version request: the generated parser
/// declares no such flag and refuses it.
#[test]
fn beside_another_argument_is_refused() {
    for args in [&["--version", "doctor"][..], &["doctor", "--version"]] {
        let answer = crate::run(args);
        assert_eq!(
            (
                answer.status,
                answer.stdout.as_str(),
                answer.stderr.as_str()
            ),
            (Some(2), "", "cli_parse\n"),
            "the answer of `ratchet {}`",
            args.join(" ")
        );
    }
}
