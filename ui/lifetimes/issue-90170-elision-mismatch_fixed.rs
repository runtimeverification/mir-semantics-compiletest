// run-rustfix

pub fn foo<'a>(x: &mut Vec<&'a u8>, y: &'a u8) { x.push(y); } //~ ERROR lifetime may not live long enough

pub fn foo2<'a>(x: &mut Vec<&'a u8>, y: &'a u8) { x.push(y); } //~ ERROR lifetime may not live long enough

pub fn foo3<'a>(_other: &'a [u8], x: &mut Vec<&'a u8>, y: &'a u8) { x.push(y); } //~ ERROR lifetime may not live long enough

fn main() {}
