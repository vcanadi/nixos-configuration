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
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };
    kernelModules = [ "coretemp" "nct6775" "it87" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  environment = {
    systemPackages = import ./modules/systemPackages.nix pkgs;

    etc = {
      "inputrc".text = ''
        set editing-mode vim
      '';
      current-nixos-config.source = ./.;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs : {
      nixos-stable = import <nixos-stable> { config = config.nixpkgs.config; };
      nixpkgs-unstable = import <nixpkgs-unstable> { config = config.nixpkgs.config; };
      nixos-unstable-small = import <nixos-unstable-small> { config = config.nixpkgs.config; };

    };
  };

  location = {
    latitude = 46.0;
    longitude = 16.0;
  };

  services = {
    openvpn.servers = {
      evpn = {
        config = ''
          config /home/vcanadi/vpn/evpn/frankfurt2.ovpn
          auth-user-pass /home/vcanadi/vpn/evpn/pass-file.txt
          '';
        autoStart = false;
        updateResolvConf = true;
      };
    };
  };

  security.polkit.enable = true;

  sound = {
    enable = true;
  };
  networking.networkmanager.enable = true;

  programs = {
    tmux = tmux-nix.tmux;
    gnupg.agent.enable = true;
  };

  hardware = {
    opengl.driSupport32Bit = true;
    pulseaudio = {
      enable = true;
      support32Bit = false;
      package = pkgs.pulseaudioFull;
    };
    # nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  time.hardwareClockInLocalTime = true;

  fonts = {
    enableDefaultFonts = true;
  };

  console = {
    font = "lat9w-12";
    useXkbConfig = true;
  };

  home-manager.users = {
   vcanadi = home-manager-config;
   root = home-manager-config;
  };

  nix.trustedUsers = [ "vcanadi" ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
}

