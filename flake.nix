{
    description = "My NixOS config";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland.url = "github:hyprwm/hyprland";

        # Optional: for zen browser if not yet in nixpkgs
        zen-browser.url = "github:0xc000022070/zen-browser-flake";
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
            nixosConfigurations.blakec = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    ./hosts/blakec
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
