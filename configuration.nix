{ config, pkgs, ... }:
{
  ###########################################################
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
    #Build all packages with pa-support
    pulseaudio = true;
  };

  virtualisation = {
    virtualbox = {
      host.enable = true;
      host.addNetworkInterface = true;
    };
    libvirtd.enable = true;
  };

  nix = {
    trustedBinaryCaches = [
      "http://cache.nixos.org"
    ];
    binaryCaches = [
      "http://cache.nixos.org"
    ];
    binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.tmpOnTmpfs = true;
  boot.loader.systemd-boot.enable = true;
  # };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "no";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Amsterdam";
  ############################################################

  #FONTS
  fonts = {
    fonts = with pkgs; [
      libertine
      tewi-font
      iosevka
      inconsolata
      dejavu_fonts
      powerline-fonts
      nerdfonts
    ];

    fontconfig.defaultFonts = {
      monospace = [ "Inconsolata Nerd Font" ];
    };
  };

  #NETWORK
  networking = {
    hostName = "nixos";
    extraHosts =
    ''
    192.168.56.3 streamstore.beat.local
    127.0.0.1 catalogservice.beat.local
    127.0.0.1 deliveryservice.beat.local
    '';
    networkmanager.enable = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
     ## system
     #xorg.xf86videonouveau
     #xf86_video_nouveau
     networkmanager
     networkmanagerapplet
     wpa_supplicant
     chromium
     firefox
     #qutebrowser
     cacert
     zsh
     oh-my-zsh
     (lib.mkOverride 10 st) # patched, see at the end of this file
     ## termutils
     nix-repl
     pstree
     tree
     slock
     jq
     fstrm
     nix-index

     ## wm
     #i3
     #i3status
     scrot

     rofi
     #dmenu
     haskellPackages.xmobar
     haskellPackages.xmonad
     haskellPackages.xmonad-contrib
     haskellPackages.xmonad-extras
     autorandr

     ## sound
     pulseaudioFull
     alsaUtils
     # pamix ## alsaUtils used instead
     cmus

     ## video
     youtube-dl
     mpv

     ## programs
     nixops
     mutt
     thunderbird
     feh
     mc
     ranger
     htop
     zathura
     weechat
     weechat-matrix-bridge

     ## dev tools
     ansible
     silver-searcher
     git
     gitAndTools.gitflow
     nix-prefetch-git
     emacs
     mu
     vim
     tmux
     taskwarrior
     virtualbox

     #postgresql100 # 10.x
     postgresql_jdbc
     redis

     ## beat-delivery
     # delivery-processor
     jpegoptim
     ffmpeg-full
     imagemagickBig
     gpac
     id3lib
     # catalogservice/deliveryservice
     cpp-hocon

     ## Python
     pypi2nix

     ## Haskell
     cabal-install
     cabal2nix

     ## Scala
     jetbrains.jdk
     scala
     sbt

     ## JS
     nodePackages.node2nix

     ## rust
     cargo

     ## utils
     cron
     unzip
     curl
     wget
     lsof
   ];

  # Enable CUPS to print.
  # services.printing.enable = true;

  #Audio
  hardware.pulseaudio.enable = true;

  #Spectre
  hardware.cpu.intel.updateMicrocode = true;

  services = {
    nginx = {
       # package = pkgs.nginx.override {
       #           modules = with pkgs.nginxModules;
       #           [ lua ];
       #           };
       user = "bbsl";
       enable = true;
       appendHttpConfig = ''
        '';
    };

    # uwsgi = {
    #   enable = true;
    #   plugins = [ "python3" "php" ];
    #   instance = {
    #     type = "normal";
    #   };
    # };


    # traefik = {
    #         enable = true;
    #         configFile = /home/bbsl/Git/beat-dev/traefik.toml;
    # };

    mysql.package = pkgs.mariadb;
    mysql.enable = true;
    # mysql.extraOptions = ''
    #	log-bin=bin.log
    #	log-bin-index=bin-log.index
    #	max_binlog_size=100M
    #	binlog_format=row
    #	'';

    redis.enable = true;
    postgresql.enable = true;
    postgresql.enableTCPIP = true;
    postgresql.package = pkgs.postgresql100;
    postgresql.authentication = pkgs.lib.mkForce ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
      '';

    xserver = {
      #Video
      videoDrivers = [ "intel" ];  ## "modesetting"
      enable = true;
      autorun = true;
      layout = "no";

      # windowManager.dwm.enable = true;
      windowManager.xmonad.enable = true;
      # windowManager.xmonad.enableContribAndExtras = true;
      # windowManager.i3.enable = true;
      windowManager.default = "xmonad";
      desktopManager.default = "none";

      xkbOptions = "eurosign:e, grp:alt_space_toggle, ctrl:nocaps";

      displayManager = {
	      lightdm.enable = true;
	      lightdm.autoLogin.enable = true;
        lightdm.greeter.enable = false;
	      lightdm.autoLogin.timeout = 0;
	      lightdm.autoLogin.user = "bbsl";
      };

      # synaptics = {
	    #   enable = true;
	    #   palmDetect = true;
	    #   twoFingerScroll = true;
      # };
      # libinput = {
      # enable = true;
      # disableWhileTyping = true;
      # };
    };
  };

  #Ghetto askpass disable so I dont get the annoying popup
  programs = {
    ssh.askPassword = "";
    ssh.startAgent = true;
    slock.enable = true;

    vim.defaultEditor = true;
    bash.enableCompletion = true;

    ##Z-shell
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh.enable = true;
      ohMyZsh.plugins = [ "git"
                          "git-flow" ];
      ohMyZsh.theme = "fishy";
    };

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bbsl = {
    shell = pkgs.zsh;
    home = "/home/bbsl";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "vboxusers"
                    "redis"
                    "git"
                    "postgres"
                    "wheel"
                    "audio"
                    "video"
                    "networkmanager" ];
  };
  users.extraGroups.vboxusers.members = [ "bbsl" ];

  # Patch with overlay
  nixpkgs.overlays = [ (self: super: {
    # Simple terminal
    st = super.st.override {
      patches = builtins.map super.fetchurl [
	  { url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.7.diff";
	    sha256 = "f721b15a5aa8d77a4b6b44713131c5f55e7fca04006bc0a3cb140ed51c14cfb6";
	  }
      ];
    };
    # dwm = super.dwm.override {
    #    patches = builtins.map super.fetchurl [
	  #  { url = "https://dwm.suckless.org/patches/alpha/dwm-alpha-6.1.diff";
	  #    sha256 = null; #wildman
	  #  }
    # { conf = builtins.readFile /home/bbsl/.config/dwm/config.h; }
    # { url = "https://raw.githubusercontent.com/Thomashrb/dwmwinkey/master/dwm-mod124-6.1.patch";
	  #   sha256 = null; #wildman
	  # }
     #  ];
     # };
    })
    (import ./overlays/dwm )
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
 system.stateVersion = "18.03"; # Did you read the comment?
}
