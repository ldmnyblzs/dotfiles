{
  description = "Balazs Ludmany's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #sops-nix = {
    #  url = "github:Mic92/sops-nix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  #outputs = inputs@{ self, nixpkgs, home-manager, sops-nix, ... }: {
  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/laptop
          home-manager.nixosModules.home-manager
	  {
	    home-manager = {
	      useGlobalPkgs = true;
	      useUserPackages = true;
	      extraSpecialArgs = { inherit inputs; };
	      users.ldmnyblzs = ./users/ldmnyblzs/home.nix;
	    };
	  }
          #sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
