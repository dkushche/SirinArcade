use std::env;
use std::path::PathBuf;
use cbindgen::Language;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    cbindgen::Builder::new()
        .with_crate(crate_dir)
        .with_language(Language::C)
        .with_src("../help-for-c/src/lib.rs")
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file("bindings.h");
}
