{ config, pkgs, lib, ... }:

let 
    dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = "br0k3r";
  home.homeDirectory = "/Users/br0k3r";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # PATH additions carried over from the old hand-written .zshrc.
  # These land in ~/.zshenv, so they apply to every shell (not just interactive).
  home.sessionPath = [
    # Homebrew's bin. /etc/zshrc adds this via `brew shellenv`, but ONLY for
    # interactive shells - and right after a reboot it's silently skipped while
    # nix-darwin activation is still wiring up /run/current-system (the `brew`
    # wrapper). Declaring it here writes it to ~/.zshenv, so brew CLIs (gls,
    # eza, ...) resolve in EVERY shell - the same reason `claude` always works.
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "$HOME/.grok/bin"      # grok cli (nigrok alias needs it)
    "$HOME/.opencode/bin"  # opencode cli
    "$HOME/.local/bin"     # user bins: uv's python3.11, etc.
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = lib.mkMerge [
      # Runs BEFORE home-manager's compinit so grok's _grok completion registers.
      (lib.mkBefore ''
        fpath=(~/.grok/completions/zsh $fpath)
      '')
      ''
        bindkey '^f' autosuggest-accept

        # nvm (installed via Homebrew) — node version manager + its completion
        export NVM_DIR="$HOME/.nvm"
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
        [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
      ''
    ];
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      opussy = "claude --dangerously-skip-permissions";
      codicks = "codex --yolo";
      nigrok = "grok --always-approve";
      ls = "gls --color=auto";
    };
  };

  programs.git = {
    enable = true;  # REQUIRED: without it home-manager writes no gitconfig and
                    # this block is inert (a stray ~/.gitconfig wins instead).
    settings.user = {
      name = "daviddkim03";
      email = "daviddkim03@gmail.com";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      # Minimal one-line prompt:  <folder>  <branch>  $   (like the old shell)
      format = "$directory$git_branch$character";
      directory = {
        style = "bold cyan";
        truncation_length = 1;      # show only the current folder name
        truncate_to_repo = false;   # don't rewrite the path to the repo root
        format = "[$path]($style) ";
      };
      git_branch = {
        symbol = " ";              # nerd-font branch glyph (nerd-fonts.hack)
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };
      character = {
        # `\$` renders a literal "$" (unescaped, starship treats $ as a variable)
        success_symbol = "[\\$](bold white)";
        error_symbol = "[\\$](bold red)";
        format = "$symbol ";
      };
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".claude/CLAUDE.md".source = 
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source = 
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source = 
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}