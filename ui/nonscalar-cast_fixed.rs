// run-rustfix

#[derive(Debug)]
struct Foo {
    x: isize
}

impl From<Foo> for isize {
    fn from(val: Foo) -> isize {
        val.x
    }
}

fn main() {
    println!("{}", isize::from(Foo { x: 1 })); //~ non-primitive cast: `Foo` as `isize` [E0605]
}
