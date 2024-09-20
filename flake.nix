{
  description = "kalscium's nixos system configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # my home-manager dots
    dots.url = "github:kalscium/dotfiles";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nix-on-droid, dots }@inputs: {
    # phone configurations
    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import nixpkgs { system = "aarch64-linux" };
      extraSpecialArgs = { inherit inputs dots; };
      modules = [ ./phone.nix ];
    };
  };
}
