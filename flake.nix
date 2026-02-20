{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.home-manager.follows = "home-manager";
        };

        nur = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        spicetify-nix = {
            url = "github:Gerg-L/spicetify-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland.url = "github:hyprwm/hyprland";
        nixvim.url = "github:steven-na/nixvim-config";
        nixcord.url = "github:kaylorben/nixcord";
    };

    outputs =
        {
            self,
            nixpkgs,
            home-manager,
            hyprland,
            ...
        }@inputs:
        {
            nixosConfigurations.bcnix = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    {
                        nixpkgs.overlays = [ inputs.nur.overlays.default ];
                        nixpkgs.config.allowUnfree = true;
                    }
                    ./hosts/bcnix
                    home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.blakec = import ./home/blakec;
                        home-manager.extraSpecialArgs = { inherit inputs; };
                    }
                ];
            };
        };
}
