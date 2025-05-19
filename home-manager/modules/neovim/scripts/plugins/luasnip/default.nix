{ lib
, pkgs
, dotfiles-flake
, ...
}:

# Support for snippets

let
  # Generate a snippet defined in VSCode's format. Because these need to reside in external JSON files they need some extra logic.
  mkVSCodeSnippet = name: jsonAttrs: {
    # Meant to be defined with `programs.nixvim.extraFiles`.
    file = {
      "snippets/${name}.json".text = lib.generators.toJSON { } {
        "${name}" = { prefix = name; } // jsonAttrs;
      };
    };

    # The snippet defined above. Note that the path is relative to the generated vimrc.
    load = ''
      require("luasnip.loaders.from_vscode").load_standalone({ path = "./snippets/${name}.json" })
    '';
  };

  # The name of the `#define` used in C/C++ header guards.
  # Taken from https://github.com/rafamadriz/friendly-snippets/blob/bedf8a06104a657678adec524b67be6806d2fead/snippets/cpp/cpp.json#L272. Thanks!
  headerGuard = ''INCLUDE''${TM_DIRECTORY/.*[\/\\](.*)/_''${1:/upcase}/}''${TM_FILENAME_BASE/(.*)/_''${1:/upcase}/}''${TM_FILENAME/.*\.(.*)/_''${1:/upcase}/}_'';

  vscodeSnippets = [
    (mkVSCodeSnippet "#cppheader" {
      description = "Header guard for C++. Format: `INCLUDE_<directory>_<filename>_<extension>_`";
      scope = "cpp";
      body = [
        "#ifndef ${headerGuard}"
        "#define ${headerGuard}"
        ""
        ''''${2:}''
        ""
        "#endif // ${headerGuard}"
      ];
    })

    (mkVSCodeSnippet "#cheader" {
      description = "Header guard for C and C++. Guard format: `INCLUDE_<directory>_<filename>_<extension>_`";
      scope = "c,cpp";
      body = [
        "#ifndef ${headerGuard}"
        "#define ${headerGuard}"
        ""
        "#ifdef __cplusplus"
        "extern \"C\" {"
        "#endif"
        ""
        ''''${2:}''
        ""
        "#ifdef __cplusplus"
        "} // extern \"C\""
        "#endif"
        ""
        "#endif // ${headerGuard}"
      ];
    })
  ];
in
{
  programs.nixvim = {
    extraFiles = lib.mergeAttrsList (lib.map (snip: snip.file) vscodeSnippets);

    extraPlugins = [
      pkgs.vimPlugins.friendly-snippets # A collection of predefined snippets
      {
        # Snippet support
        plugin = pkgs.vimPlugins.luasnip;
        config = dotfiles-flake.lib.vim.mkLua ''
          dofile("${./luasnip.lua}")
          ${lib.concatMapStringsSep "\n" (snip: snip.load) vscodeSnippets}
        '';
      }
    ];
  };
}
