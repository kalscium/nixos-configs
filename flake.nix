{
  description = "kalscium's nixos system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # my home-manager dots
    # dots.url = "github:kalscium/dotfiles";
    dots.url = "path:/home/kalscium/Github/dotfiles";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hypridle.url = "github:hyprwm/hypridle";
    hyprlock.url = "github:hyprwm/hyprlock";
  };

  outputs = { self, nixpkgs, nix-on-droid, home-manager, hyprland, dots, ... }@inputs: {
    # phone configurations
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs dots; };
      modules = [ ./phone.nix ];
    };

    # NixOS Configurations
    nixosConfigurations =
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      # For my default system
      kalnix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs hyprland pkgs; };
        modules = [
          hyprland.nixosModules.default
          home-manager.nixosModules.home-manager
          dots.services.default
          ./laptop/configuration.nix
        ];
      };
    };

    # home-manager
    homeConfigurations = 
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in {
      "kalscium" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };

        modules = with dots; [
          ./git.nix
          {
            home.stateVersion = "24.05";
            home.username = "kalscium";
            home.homeDirectory = "/home/kalscium";
          }
          common
          graphical.default
          terminal.default
          terminal.zsh.user
        ];
      };
      "root" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };

        modules = with dots; [
          {
            home.stateVersion = "24.05";
            home.username = "root";
            home.homeDirectory = "/root";
          }
          common
          terminal.default
          terminal.zsh.root
        ];
      };
    };
  };
}
