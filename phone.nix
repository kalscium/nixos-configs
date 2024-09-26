{ dots, ... }: {
  system.stateVersion = "24.05";

  # Set up nix for flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Set your time zone
  time.timeZone = "Australia/Melbourne";

  # Configure home-manager
  home-manager = {
    useGlobalPkgs = true;
    config = {
      imports = [
        ./git.nix
        # use my home-manager dots
        dots.common
        dots.terminal.default
        dots.terminal.zsh.user
      ];
    };
  };
}
