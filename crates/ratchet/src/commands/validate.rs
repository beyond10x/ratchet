//! `ratchet validate`.

use cli_contract::{HandlerReply, Invocation};

/// Not built yet: the unavailable answer.
pub fn call(_invocation: &Invocation<'_>) -> HandlerReply {
    HandlerReply::Unavailable
}
