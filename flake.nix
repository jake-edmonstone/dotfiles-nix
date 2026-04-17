{
  description = "Jake's system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Determinate Nix's nix-darwin module — handles nix-darwin interop,
    # exposes GC tuning + custom nix.conf via determinateNix options.
    # (No nixpkgs.follows — docs explicitly warn against it to keep
    # FlakeHub Cache artifacts usable.)
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Tracks upstream @anthropic-ai/claude-code within ~30 min via hourly
    # GitHub Actions. The nixpkgs claude-code trails by 5-10 versions.
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, determinate, nix-darwin, home-manager, nix-homebrew, claude-code, ... }: {

    darwinConfigurations."Jakes-MacBook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/darwin
        determinate.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        { nixpkgs.overlays = [ claude-code.overlays.default ]; }
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = { isCerebras = false; };
          home-manager.users.jbedm = import ./home/darwin.nix;
        }
      ];
    };

    # Keyed as "<user>@<hostname>" so bare `home-manager switch --flake .`
    # auto-resolves (home-manager's CLI tries $USER@$(hostname) variants).
    # isCerebras is hardcoded true here because the attr key already names
    # the Cerebras host — builtins.pathExists is unavailable in pure flake
    # eval for paths outside the flake tree, so we can't detect at runtime.
    homeConfigurations."jakee@jakee-vm" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ claude-code.overlays.default ];
      };
      extraSpecialArgs = { isCerebras = true; };
      modules = [ ./home/cerebras.nix ];
    };
  };
}
