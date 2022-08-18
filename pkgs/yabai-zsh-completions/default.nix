{ lib
, runCommandNoCC
, fetchFromGitHub
, installShellFiles
, yabai
}:

runCommandNoCC "yabai-zsh-completions" {
  pname = "yabai-zsh-completions";
  version = "0.pre+date=2022-05-25";

  src = fetchFromGitHub {
    owner = "Amar1729";
    repo = "yabai-zsh-completions";
    rev = "5b096ee3a63ebc3fb32765704eb434af9388e323";
    sha256 = "sha256-gWSYNkdljzdBeB7DmdSwzENQURdueJJVPXtFY4bA4BI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  meta = with lib; {
    homepage = "https://github.com/Amar1729/yabai-zsh-completions";
    description = "zsh completions for yabai, the tiling window manager";
    license = licenses.mit;
    platforms = yabai.meta.platforms;
    maintainers = with maintainers; [ ivar ];
  };
} ''
  installShellCompletion --zsh $src/_yabai
''
