{ pkgs, hyprland, ... }:
let
  hyprland-pkgs = hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # Enable the AMD graphics card driver
  boot.initrd.kernelModules = [ "amdgpu"];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [ "ext4" "ntfs" "btrfs" ];

  # Networking
  networking = {
    hostName = "kalnix"; # Defines your hostname
    # wireless.enable = true; # Enables wireless support via `wpa_supplicant`
    networkmanager.enable = true; # Enables networking (like wifi)
  };

  
  # Some extra OpenGL configs
  hardware.nvidia.modesetting.enable = true;
  hardware.graphics = {
    enable = true;

    package = hyprland-pkgs.mesa.drivers;
    package32 = hyprland-pkgs.pkgsi686Linux.mesa.drivers;

    extraPackages = with hyprland-pkgs; [
      # OpenCL
      rocmPackages.clr.icd
      amdvlk
    ];

    # For 32bit apps
    extraPackages32 = with hyprland-pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  # Enable Nix LD
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  time.timeZone = "Australia/Melbourne"; # time zone

  # Select internationalisation properties
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable touchpad support (enabled default in most desktop managers)
  services.libinput.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = { # to enable wifi printing
    enable = true;
    # nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Set zsh as default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enable home-manager
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  # Defines my user account
  # (Don't forget to set a password with `passwd`)
  users.users.kalscium = {
    isNormalUser = true;
    description = "Kalscium";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "uinput" ];
  };

  system.stateVersion = "24.05";

  # Enable flakes and nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Installed fonts
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  # Environmental Variables
  environment.variables = {
    PATH = [
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ];
  };
}
