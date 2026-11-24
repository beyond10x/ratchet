//! The `ratchet` command line.
//!
//! The parser, the help text and the process adapter come from the generated package
//! `ratchet-cli-contract` (`ess generate cli` over `spec/cli.yaml`). This crate supplies what
//! the generated code leaves open: the handler behind each command, in `commands`.

mod commands;

fn main() {
    let output = cli_contract::run(
        std::env::args_os().collect(),
        &mut cli_contract::OsSources,
        &mut commands::Commands,
        None,
    );
    print!("{}", output.stdout);
    eprint!("{}", output.stderr);
    std::process::exit(output.exit_code);
}
