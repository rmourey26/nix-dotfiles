
 # Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:    

{
  nix.package = pkgs.nixFlakes;
  nix.useSandbox = true;
  nix.autoOptimiseStore = true;
  nix.readOnlyStore = false;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    keep-outputs = true
    keep-derivations = true
  '';

  imports =
    [
    ./hardware-configuration.nix
    ];
  
  nix.buildMachines = [
    { hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
      maxJobs = 8;
    }
  ];
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;
  networking.hostName = "nixos"; # Define your hostname.
  # Define additional host names
  networking.extraHosts = '' 
    127.0.0.2 other-localhost
    10.0.0.1 server
  '';  
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  #Nixpks
  nixpkgs.config.allowUnfree = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.gnome.core-developer-tools.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.desktopManager.mate.enable = false;
  services.xserver.windowManager.xmonad.enable = false;
  services.postfix = {
    enable = true;
    setSendmail = true;
  };
  # Configure keymap in X11
  services.xserver.layout ="us";
  # services.xserver.xkbOptions = "eurosign:e";
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Sandboxes
  programs.sway.enable = false;
  xdg = {
    portal = {
      enable = true;
   };
  };
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rmourey26 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "deployer" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ "/etc/ssh/authorized_keys.d/xxxxxx" "/etc/ssh/authorized_keys.d/xxxxxx" ];
    packages = with pkgs; [
      python39Full
    ]; 
  };
  
 # home-manager.users.rmourey26 = { ... }: {   
 #   home.packages = [ pkgs.atool pkgs.httpie pkgs.python39Full ];
 #     programs.bash.enable = true;
 #     programs.git = {
 #       enable = true;
 #       userName = "rmourey26";
 #       userEmail = "rmourey_jr@quantumone.network";
 #     };
 # };

 # Entrusting the Nixops deployer

  nix.trustedUsers = [ "deployer" "rmourey26" "hydra" "hydra-evaluator" "hydra-queue-runner"  ];
  users.users.deployer.group = "deployer";
  security.sudo.wheelNeedsPassword = false;
  users.users.deployer = {
    isSystemUser = true;
  };
  # VS Code on Wayland
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-toolsai.jupyter
        ms-vscode.cpptools
        ms-dotnettools.csharp
        ms-vsliveshare.vsliveshare
        terraform
        chenglou92.rescript-vscode
        vadimcn.vscode-lldb
        ms-vscode-remote.remote-ssh
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
      ];
    })
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gh
    inotify-tools
    texlive.combined.scheme-basic
    vivaldi
    vivaldi-widevine
    vivaldi-ffmpeg-codecs
    libreoffice
    pandoc
    openjdk
    perl
    vscode
    google-cloud-sdk-gce
    binutils
    gnutls
    firefox
    nodejs_latest
    bind
    direnv
    google-chrome
    mkpasswd
    cachix
    shutter
    docker
    docker-compose
    android-studio 
    go
    awscli
    gimp 
    python3
    python2
    obs-studio 
    yarn2nix
    cabal2nix  
  ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.seahorse.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
      forwardX11 = true;
      ports = [ 2022 ];
  };
  programs.dconf.enable = true;
  virtualisation.docker.enable = true;
  services.lorri.enable = true;
  services.flatpak.enable = true;
  services.hydra = {
    enable = true;
    port = 3333;
    hydraURL = "https://hydra.blockchain-company.io";
    notificationSender = "hydra@hydra.blockchain-company.io";
    buildMachinesFiles = [];
    useSubstitutes = true;
    logo = "/var/lib/hydra/www/qone-color.png";
  };
  services.yggdrasil = {
    enable = true;
    persistentKeys = false;
      # The NixOS module will generate new keys and a new IPv6 address each time
      # it is started if persistentKeys is not enabled.

    config = {
      Peers = [
        # Yggdrasil will automatically connect and "peer" with other nodes it
        # discovers via link-local multicast annoucements. Unless this is the
        # case (it probably isn't) a node needs peers within the existing
        # network that it can tunnel to.
        "tcp://1.2.3.4:1024"
        "tcp://1.2.3.5:1024"
        # Public peers can be found at
        # https://github.com/yggdrasil-network/public-peers
      ];
    };
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    media-session.config.bluez-monitor.rules = [
    {
      # Matches all cards
      matches = [ { "device.name" = "~bluez_card.*"; } ];
      actions = {
        "update-props" = {
          "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          # mSBC is not expected to work on all headset + adapter combinations.
          "bluez5.msbc-support" = true;
          # SBC-XQ is not expected to work on all headset + adapter combinations.
          "bluez5.sbc-xq-support" = true;
        };
      };
    }
    {
      matches = [
        # Matches all sources
        { "node.name" = "~bluez_input.*"; }
        # Matches all outputs
        { "node.name" = "~bluez_output.*"; }
      ];
     }
   ];
  }; 
  
  security.acme.acceptTerms = true;
  security.acme.email = "rmourey_jr@da-fi.com";
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 20 22 80 443 53 111 113 2049 2077 1080 3000 5432 8125 9198 9199 63333 27017 422 4400 42224 9099 8080 ];
  networking.firewall.allowedUDPPorts = [ 20 22 80 443 53 111 113 2049 2077 1080 3000 5432 8125 9198 9199 63333 27017 422 4400 42224 9099 8080 ];
  networking.firewall.allowedTCPPortRanges = [
  { from = 512; to = 515; }
  { from = 4000; to = 4007; }
  { from = 6000; to = 6069; }
  { from = 8000; to = 8010; }
  { from = 3000; to = 3200; }
  { from = 8500; to = 8600; }
  { from = 5500; to = 5600; }
  ];
  networking.firewall.allowedUDPPortRanges = [
  { from = 512; to = 515; }
  { from = 4000; to = 4007; }
  { from = 6000; to = 6069; }
  { from = 8000; to = 8010; }
  { from = 3000; to = 3200; }
  { from = 8500; to = 8600; }
  { from = 5500; to = 5600; }
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.defaultGateway = "10.207.0.254";
  networking.nameservers = [ "1.1.1.1" ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
