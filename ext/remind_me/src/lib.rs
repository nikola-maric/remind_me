pub mod scanner;

#[cfg(feature = "ruby")]
use magnus::{function, prelude::*, Error, Ruby};

#[cfg(feature = "ruby")]
fn scan_for_remind_me_comments(path: String) -> Result<Vec<(String, String)>, Error> {
    Ok(scanner::scan_for_remind_me_comments(&path))
}

#[cfg(feature = "ruby")]
#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("RemindMe")?;
    let native = module.define_module("Native")?;
    native.define_module_function(
        "scan_for_remind_me_comments",
        function!(scan_for_remind_me_comments, 1),
    )?;
    Ok(())
}
