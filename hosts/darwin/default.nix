{ pkgs, ... }:

{
  system.primaryUser = "jbedm";
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.pam.services.sudo_local.touchIdAuth = true;

  programs.zsh.enable = true;

  fonts.packages = [
    pkgs.maple-mono.NF
  ];

  # ---------------------------------------------------------------------------
  # Homebrew (GUI apps only — CLI tools are in nixpkgs)
  # ---------------------------------------------------------------------------
  nix-homebrew = {
    enable = true;
    user = "jbedm";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    casks = [
      "hammerspoon"
      "raycast"
      "spotify"
      "stats"
    ];
    masApps = {
      Goodnotes = 1444383602;
    };
  };

  # ---------------------------------------------------------------------------
  # macOS defaults
  # ---------------------------------------------------------------------------
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = true;
      tilesize = 64;
    };

    finder = {
      AppleShowAllFiles = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "clmv";
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowPathbar = true;
      ShowRemovableMediaOnDesktop = true;
      ShowStatusBar = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = true;
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    screencapture = {
      disable-shadow = true;
      location = "~/Desktop";
      type = "png";
    };

    WindowManager = {
      EnableTiledWindowMargins = false;
      EnableTilingByEdgeDrag = true;
      EnableTilingOptionAccelerator = false;
      EnableTopTilingByEdgeDrag = true;
      HideDesktop = true;
      StageManagerHideWidgets = false;
      StandardHideWidgets = false;
    };

    trackpad.Clicking = true;

    CustomUserPreferences = {
      "com.apple.finder" = {
        ShowSidebar = true;
      };
      "com.raycast.macos" = {
        useHyperKeyIcon = true;
        raycastShouldFollowSystemAppearance = true;
        raycast_hyperKey_state = {
          enabled = true;
          includeShiftKey = true;
          keyCode = 230;
        };
      };
    };
  };

  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall Finder || true
    killall SystemUIServer || true
    killall Raycast || true
  '';
}
