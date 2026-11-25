//! The handler of each command the binding declares.
//!
//! A command that a story builds has a file of its own here, with one function `call`, and a
//! row in `BUILT`. The story that builds the command edits that file and not this one. Every
//! other command shares `unbuilt`.

mod assess;
mod evaluate;
mod reference_adopt;
mod validate;

use cli_contract::{Handler, HandlerReply, Invocation};

/// The function `call` of a command file.
type Call = fn(&Invocation<'_>) -> HandlerReply;

/// The commands a story builds: the callable of the binding and the function that answers it.
/// A key that is no callable of the binding would never be selected; the test below refuses it.
const BUILT: [(&str, Call); 4] = [
    ("validate", validate::call),
    ("assess", assess::call),
    ("reference-adopt", reference_adopt::call),
    ("evaluate", evaluate::call),
];

/// The handlers of the `ratchet` commands, selected by the callable of the binding.
pub struct Commands;

impl Handler for Commands {
    fn call(&mut self, invocation: &Invocation<'_>) -> HandlerReply {
        match BUILT
            .iter()
            .find(|(callable, _)| *callable == invocation.callable)
        {
            Some((_, call)) => call(invocation),
            None => unbuilt(invocation),
        }
    }
}

/// The answer of the twelve commands no story has built: `init`, `reference propose`, `prove`,
/// `render`, `status`, `explain`, `history`, `diff`, `doctor`, `import`, `exceptions` and
/// `serve`. The generated adapter turns it into exit status 1 and the code
/// `cli_handler_unavailable`.
fn unbuilt(_invocation: &Invocation<'_>) -> HandlerReply {
    HandlerReply::Unavailable
}

#[cfg(test)]
mod tests {
    use super::BUILT;

    /// Each key of `BUILT` is the callable of a command the binding declares, and no key is
    /// there twice: a row with a misspelt key would leave its command on `unbuilt` for good.
    #[test]
    fn built_commands_are_callables_of_the_binding() {
        let plan = cli_contract::plan();
        for (index, (callable, _)) in BUILT.iter().enumerate() {
            assert!(
                plan.commands
                    .iter()
                    .any(|command| command.callable == *callable),
                "`{callable}` is a key of BUILT and the callable of no command in the binding"
            );
            assert!(
                BUILT[..index]
                    .iter()
                    .all(|(earlier, _)| earlier != callable),
                "`{callable}` is a key of BUILT twice"
            );
        }
    }
}
