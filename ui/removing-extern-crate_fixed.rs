// edition:2018
// aux-build:removing-extern-crate.rs
// run-rustfix
// check-pass

#![warn(rust_2018_idioms)]

 //~ WARNING unused extern crate
 //~ WARNING unused extern crate

mod another {
     //~ WARNING unused extern crate
     //~ WARNING unused extern crate
}

fn main() {}
