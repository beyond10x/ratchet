//! The handler of each command the binding declares.
//!
//! A command that a story builds has a file of its own here, with one function `call`. The
//! story that builds the command edits that file and not this one. Every other command shares
//! `unbuilt`.

mod assess;
mod evaluate;
mod reference_adopt;
mod validate;

use cli_contract::{Handler, HandlerReply, Invocation};

/// The handlers of the `ratchet` commands, selected by the callable of the binding.
pub struct Commands;

impl Handler for Commands {
    fn call(&mut self, invocation: &Invocation<'_>) -> HandlerReply {
        match invocation.callable {
            "validate" => validate::call(invocation),
            "assess" => assess::call(invocation),
            "reference-adopt" => reference_adopt::call(invocation),
            "evaluate" => evaluate::call(invocation),
            _ => unbuilt(invocation),
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
