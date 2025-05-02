{ lib
, runCommand
, makeWrapper
}:

# A function which creates a shell script with optional dependencies added to PATH.

name:
src:
{ dependencies ? [ ]
, ...
} @ attrs:

runCommand name ({
  inherit src;
  nativeBuildInputs = lib.optionals (dependencies != [ ])
    (attrs.nativeBuildInputs or [ ]) ++ [ makeWrapper ];

  meta = { mainProgram = name; } // attrs.meta or { };
} // (builtins.removeAttrs attrs [ "nativeBuildInputs" "meta" ])) ''
  mkdir -p $out/bin
  install -Dm755 $src $out/bin/$name
  patchShebangs $out/bin/$name

  ${lib.optionalString (dependencies != [ ]) ''
    wrapProgram $out/bin/$name --prefix PATH : ${lib.makeBinPath dependencies}
  ''}
''
