# frozen_string_literal: true

require 'mkmf'

if system('cargo --version > /dev/null 2>&1')
  require 'rb_sys/mkmf'
  create_rust_makefile('remind_me/remind_me_native')
else
  File.write('Makefile', "all:\ninstall:\n")
  $stderr.puts 'WARNING: Rust toolchain not found, skipping native extension build. Using pure-Ruby fallback.'
end
remind_me_native::scanner::scan_for_remind_me_comments::{{closure}}::{{closure}} [/Users/nikola/git_clones/remind_me/ext/remind_me/src/scanner.rs]
<alloc::boxed::Box<F,A> as core::ops::function::FnMut<Args>>::call_mut [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/alloc/src/boxed.rs]
<ignore::walk::FnVisitorImp as ignore::walk::ParallelVisitor>::visit [ignore-0.4.25/src/walk.rs]
ignore::walk::Worker::run_one [ignore-0.4.25/src/walk.rs]
ignore::walk::Worker::run [ignore-0.4.25/src/walk.rs]
ignore::walk::WalkParallel::visit::{{closure}}::{{closure}}::{{closure}} [ignore-0.4.25/src/walk.rs]
std::sys::backtrace::__rust_begin_short_backtrace [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/sys/backtrace.rs]
std::thread::Builder::spawn_unchecked_::{{closure}}::{{closure}} [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/thread/mod.rs]
<core::panic::unwind_safe::AssertUnwindSafe<F> as core::ops::function::FnOnce<()>>::call_once [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/core/src/panic/unwind_safe.rs]
std::panicking::catch_unwind::do_call [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/panicking.rs]
std::panicking::catch_unwind [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/panicking.rs]
std::panic::catch_unwind [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/panic.rs]
std::thread::Builder::spawn_unchecked_::{{closure}} [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/thread/mod.rs]
core::ops::function::FnOnce::call_once{{vtable.shim}} [/Users/nikola/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/library/core/src/ops/function.rs]
<alloc::boxed::Box<F,A> as core::ops::function::FnOnce<Args>>::call_once [library/alloc/src/boxed.rs]
std::sys::thread::unix::Thread::new::thread_start [library/std/src/sys/thread/unix.rs]
_pthread_start [libsystem_pthread.dylib]
thread_start [libsystem_pthread.dylib]