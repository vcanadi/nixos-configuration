{ config, pkgs, ... }:
let
  utils = import ./utils.nix config;
  home-manager-config = import ./home.nix;
  tmux-nix = import ./modules/tmux.nix { inherit pkgs; };
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/X.nix
    ./modules/users.nix
    <home-manager/nixos>
   ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
      };
      timeout = 2;
    };
    kernelModules = [ "coretemp" "nct6775" "it87" ];
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ext4" "vfat" "ntfs" ];
  };

  environment = {
    systemPackages = (import ./modules/systemPackages.nix pkgs).systemPackages;
    etc = {
      "inputrc".text = ''
        set editing-mode vim
      '';
      current-nixos-config.source = ./.;
    };
  };

  swapDevices = [{
    device = "/swapfile";
    size = 32 * 1024;
  }];

  nixpkgs = {
    config = {
      android_sdk.accept_license = true;
      allowUnfree = true;

      packageOverrides = pkgs : {
        nixos-stable = import <nixos-stable> { config = config.nixpkgs.config; };
        nixpkgs-unstable = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
        nixos-unstable-small = import <nixos-unstable-small> { config = config.nixpkgs.config; };
        nixos-cloned = import /home/vcanadi/git/nixpkgs { config = config.nixpkgs.config; };
      };
    };
    overlays = (import ./modules/systemPackages.nix pkgs).overlays;
  };

  location = {
    latitude = 46.0;
    longitude = 16.0;
  };

  security.polkit.enable = true;

  services = {

    openssh.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
    };
    # blueman.enable = true;
  };

  networking.networkmanager.enable = true;

  programs = {
    zsh.enable = true;
    tmux = tmux-nix.tmux;
    gnupg.agent.enable = true;
  };

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
  };

  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Zagreb";
  };

  fonts = {
    enableDefaultPackages = true;
  };

  console = {
    font = "lat9w-12";
    useXkbConfig = true;
  };

  home-manager.users = {
    vcanadi = home-manager-config;
    root = home-manager-config;
  };

  nix = {
    settings = {
      trusted-users = [ "vcanadi" ];
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
  # system.activationScripts = utils.mkActivationScriptsForUsers [ tmux-nix.tmuxp.userActivationScript ];
  system.stateVersion = "unstable";

  # virtualisation = {
  #   virtualbox.host = {
  #     enable = true;
  #     # enableHardening = false;
  #     package = pkgs.nixos-stable.pkgs.virtualbox;
  #     enableExtensionPack = true;
  #   };
  #   docker = {
  #     enable =  true;
  #   };
  #   libvirtd.enable = true;
  # };

}

