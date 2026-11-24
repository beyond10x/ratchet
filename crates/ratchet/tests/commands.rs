//! The commands of `spec/cli.yaml` that no story of 0.1.0 builds.

/// The command path and the arguments its declaration requires, one row per command.
const UNBUILT: [(&[&str], &[&str]); 12] = [
    (&["init"], &[]),
    (&["reference", "propose"], &[]),
    (&["prove"], &[]),
    (&["render"], &[]),
    (&["status"], &[]),
    (&["explain"], &["no-lint-findings"]),
    (&["history"], &["no-lint-findings"]),
    (&["diff"], &[]),
    (&["doctor"], &[]),
    (&["import"], &["junit", "--assessment", "unit-tests"]),
    (&["exceptions"], &[]),
    (&["serve"], &[]),
];

/// The commands a later story of 0.1.0 builds; each has its own test file.
const BUILT_LATER: [&[&str]; 4] = [
    &["validate"],
    &["assess"],
    &["reference", "adopt"],
    &["evaluate"],
];

#[test]
fn unbuilt_commands_answer_unavailable() {
    let mut listed: Vec<Vec<String>> = UNBUILT
        .iter()
        .map(|(path, _)| *path)
        .chain(BUILT_LATER)
        .map(|path| path.iter().map(|word| (*word).to_owned()).collect())
        .collect();
    listed.sort();
    let mut declared: Vec<Vec<String>> = cli_contract::plan()
        .commands
        .into_iter()
        .map(|command| command.path)
        .collect();
    declared.sort();
    assert_eq!(
        listed, declared,
        "the rows of this file and the four commands built later are the commands the binding declares"
    );

    for (path, required) in UNBUILT {
        let args: Vec<&str> = path.iter().chain(required).copied().collect();
        crate::assert_unavailable(&args);
    }
}
