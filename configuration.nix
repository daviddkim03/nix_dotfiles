{ ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = "br0k3r";
  users.users.br0k3r = {
    home = "/Users/br0k3r";
  };
  system.stateVersion = 6;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };

  nix-homebrew = {
    enable = true;
    user = "br0k3r";
    # Take over the pre-existing /opt/homebrew. This deletes the old Homebrew
    # install and re-creates it under nix-homebrew management, KEEPING every
    # already-installed formula/cask. Without this, activation aborts at
    # "setting up Homebrew" and never reaches home-manager.
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    # Enable ONLY after a clean rebuild confirms every installed brew/cask
    # below is listed — otherwise "zap" uninstalls (and wipes data for)
    # anything not declared here.
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];

    # Top-level formulae (`brew leaves`). Dependencies are kept automatically.
    brews = [
      "cask"
      "cmake"
      "cmatrix"
      "cocoapods"
      "colima"
      "commitizen"
      "docker"
      "docker-compose"
      "eza"
      "ffmpeg"
      "gh"
      "git"
      "herdr"
      "jq"
      "lld"
      "makensis"
      "nvm"
      "openjdk@17"
      "openjdk@21"
      "pkgconf"
      "pnpm"
      "qt"
      "railway"
      "rustup"
      "starship"
      "swiftformat"
      "swiftlint"
      "tailscale"
      "vite"
      "watchman"
      "wget"
      "xcodegen"
      "xcodes"
    ];
    casks = [
      "bitwarden"
      "brave-browser"
      "calibre"
      "claude-code"
      "codex"
      "discord"
      "firefox"
      "flameshot"
      "flutter"
      "font-hack-nerd-font"
      "gcloud-cli"
      "google-chrome"
      "iterm2"
      "jordanbaird-ice"
      "maccy"
      "ngrok"
      "raycast"
      "rectangle"
      "shotcut"
      "utm"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "zoom"
    ];
  };
}