{
   description = "Robert Mourey Jr's Nix system configuration";

   inputs = {
     nixpkgs.url = "nixpkgs/nixos-21.11";
     vscode-server.url = "github:msteen/nixos-vscode-server";
     home-manager.url = "github:nix-community/home-manager";
     home-manager.inputs.nixpkgs.follows = "nixpkgs";
   };

   outputs = {self, nixpkgs, home-manager, vscode-server,...}:
   let
     system = "x86_64-linux";
     
     pkgs= import nixpkgs {
       inherit system;
       config = {allowUnfree = true; }; 
     };
    
     lib = nixpkgs.lib;

   in {
     nixosConfigurations = {
       nixos = lib.nixosSystem {
         inherit system;
    
         modules = [
            ./configuration.nix
            vscode-server.nixosModule
           ({ config, pkgs, ... }: {
            services.vscode-server.enable = true;
           })
         ];
       };
     };
   };
}
       