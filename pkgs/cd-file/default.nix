{
  createScript,
}:

createScript "cd-file" ./cd-file.sh {
  meta.description = "automatically cd to the directory a file is located in";
}
