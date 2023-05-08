{ lib
, vimUtils
, fetchFromGitHub
}:

{
  vim-just = vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-just";
    version = "0.pre+date=2022-11-02";

    src = fetchFromGitHub {
      owner = "NoahTheDuke";
      repo = "vim-just";
      rev = "838c9096d4c5d64d1000a6442a358746324c2123";
      sha256 = "sha256-DSC47z2wOEXvo2kGO5JtmR3hyHPiYXrkX7MgtagV5h4=";
    };

    meta = with lib; {
      description = "Vim syntax files for justfiles";
      homepage = "https://github.com/NoahTheDuke/vim-just";
      license = licenses.mit;
    };
  };

  vim-gas = vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-gas";
    version = "0.pre+date=2022-03-07";

    src = fetchFromGitHub {
      owner = "Shirk";
      repo = "vim-gas";
      rev = "2ca95211b465be8e2871a62ee12f16e01e64bd98";
      sha256 = "sha256-pu2EvKA5YEUhBdAG0eMuPBdKY+VdXmJsEILzq9Mrh9E=";
    };

    meta = with lib; {
      description = "Advanced syntax highlighting for GNU Assembler";
      homepage = "https://github.com/Shirk/vim-gas";
      license = licenses.bsd3;
    };
  };
}
