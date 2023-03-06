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
}
