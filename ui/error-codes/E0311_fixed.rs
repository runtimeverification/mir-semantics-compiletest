// run-rustfix

#![allow(warnings)]

fn no_restriction<'a, T: 'a>(x: &'a ()) -> &() {
    with_restriction::<T>(x) //~ ERROR E0311
}

fn with_restriction<'a, T: 'a>(x: &'a ()) -> &'a () {
    x
}

fn main() {}
