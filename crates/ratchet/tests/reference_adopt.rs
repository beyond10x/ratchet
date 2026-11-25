//! `ratchet reference adopt`. The story that builds the command replaces this test with its own.

#[test]
fn unavailable() {
    crate::assert_unavailable(&["reference", "adopt"]);
}
