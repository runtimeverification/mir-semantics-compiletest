// run-rustfix
fn main() {
    #[allow(non_upper_case_globals)]
    const foo: isize = 100;

    #[derive(Debug)]
    enum Stuff {
        Bar = foo
        //~^ ERROR attempt to use a non-constant value in a constant
    }

    println!("{:?}", Stuff::Bar);
}
