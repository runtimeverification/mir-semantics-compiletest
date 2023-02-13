// run-rustfix
use std::pin::Pin;

struct Foo;

impl Foo {
    fn foo(self: Pin<&mut Self>) {}
}

fn main() {
    let mut foo = Foo;
    let mut foo = Pin::new(&mut foo);
    foo.as_mut().foo();
    foo.foo(); //~ ERROR use of moved value
}
