{
  createScript,
}:

createScript "qute-docsrs" ./docsrs.sh {
  meta.description = "Shortcut to search docs.rs for Rust documentation";
}
