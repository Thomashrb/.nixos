{ config, pkgs, ... }:

{
  ###########################################################
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowBroken = true;
    import = "/home/bbsl/.config/nixpkgs/config.nix";
    allowUnfree = true;
  };

  nix = {
    trustedBinaryCaches = [
      "http://hydra.nixos.org"
      "http://cache.nixos.org"
    ];
    binaryCaches = [
      "http://hydra.nixos.org"
      "http://cache.nixos.org"
    ];
    binaryCachePublicKeys = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ]; 
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    networkmanager.enable = true;
    # hostId = "847849e7";
    # interfaceMonitor.enable = false;
    # wireless.enable = true;
    # wireless.interfaces = [ "wlp4s0" ];
    # wireless.userControlled.enable = true;
    # wireless.userControlled.group = "network";
    useDHCP = false;
    # nameservers = [ "192.168.1.254" ];
    # wicd.enable = true;
    # extraHosts = ''
    #   127.0.0.1 db
    # '';
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
     ## system
     xorg.xf86videonouveau
     xf86_video_nouveau 
     networkmanager
     chromium
     firefox
     (pkgs.lib.mkOverride 10 surf)
     #fish
     zsh
     oh-my-zsh
     (pkgs.lib.mkOverride 10 st) # patched, see at the end of this file
     ## termutils
     pstree
     tree
     scrot
     slock
     jq

     ## wm
     i3
     i3status
     scrot
     rofi
     surfraw
  
     ## sound 
     pulseaudioFull
     cmus
     pamix

     ## video
     ffmpeg-full
     youtube-dl
     mpv

     ## programs
     feh
     mc
     ranger
     htop
     zathura
     weechat

     ## dev tools
     silver-searcher
     git
     nix-prefetch-git
     emacs
     neovim
     tmux
     postgresql
     redis
     cpp-hocon

     ## langs
     ## Python
     python
     pypi2nix

     ## Haskell
     cabal-install
     cabal2nix

     ## Scala
     jetbrains.jdk
     scala
     sbt

     ## utils
     cron
     unzip
     curl
     wget
     lsof
   ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
  #Video
  #videoDrivers = [ "intel" "modesetting" ];

  #Sound
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services = {
    # openssh = {
    #   enable = true;
    #   openssh.passwordAuthentication = false;
    # };

    emacs.defaultEditor = true;
    
    postgresql.enable = true;
    postgresql.package = pkgs.postgresql94;
        
    xserver = {
      enable = true;
      autorun = true;
      layout = "no";
    
      windowManager.i3.enable = true;
      windowManager.default = "i3";
      desktopManager.default = "none";
   
      xkbOptions = "eurosign:e, grp:alt_space_toggle, ctrl:nocaps";

      synaptics = {
        enable = true;
        palmDetect = true;
        twoFingerScroll = true;
      };
      
      displayManager = {
        slim.enable = false;
        sddm.enable = false;
        lightdm.enable = true;
        lightdm.autoLogin.enable = false;
        lightdm.autoLogin.user = "bbsl";
      };
        
      #libinput = {
      #enable = true;
      #disableWhileTyping = true;
      #};
    };
  };

  #Ghetto askpass disable so I dont get the annoying popup
  programs = {
    ssh.askPassword = "";
    ssh.startAgent = true;
    slock.enable = true;
    #fish.enable = true;
    
    #vim.defaultEditor = true;
  
    ##Z-shell
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
      ohMyZsh.plugins = [ "git" ];
      ohMyZsh.theme = "lambda";
    };  
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.bbsl = {
    shell = pkgs.zsh;
    home = "/home/bbsl";
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ]; 
    # openssh.authorizedKeys.keys = [ 
    #   "ssh-rsa "
    # ];
  };

  # Patch with overlay
  nixpkgs.overlays = [ (self: super: {
    # Simple terminal
    st = super.st.override {
      patches = builtins.map super.fetchurl [
          { url = "https://st.suckless.org/patches/solarized/st-no_bold_colors-0.7.diff";
            sha256 = "2e8cdbeaaa79ed067ffcfdcf4c5f09fb5c8c984906cde97226d4dd219dda39dc"; 
          }
          { url = "https://st.suckless.org/patches/solarized/st-solarized-light-0.7.diff";
            sha256 = "d3f28d2a78647e52e64ff2a41df96802787ea15deb168a585c09a9f5cf2ba066"; 
          }
          { url = "https://st.suckless.org/patches/scrollback/st-scrollback-0.7.diff";
            sha256 = "f721b15a5aa8d77a4b6b44713131c5f55e7fca04006bc0a3cb140ed51c14cfb6"; 
          }
        ];
    };
    # Surf browser
    surf = super.surf.override {
      patches = builtins.map super.fetchurl [
        { url = "https://surf.suckless.org/patches/surf-spacesearch-20170408-b814567.diff";
          sha256 = "4d69aa961419720b04333c13ce06cb98b37e957b68d69eec8f761391af5ba65a";
        }
      ];
    };
  }) ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?
}
