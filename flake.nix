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
  };

  outputs = { nixpkgs, determinate, nix-darwin, home-manager, nix-homebrew, ... }: {

    darwinConfigurations."Jakes-MacBook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/darwin
        determinate.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
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
    # isCerebras auto-detects via /cb presence — same marker nvim uses.
    homeConfigurations."jakee@jakee-vm" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { isCerebras = builtins.pathExists "/cb"; };
      modules = [ ./home/cerebras.nix ];
    };
  };
}
