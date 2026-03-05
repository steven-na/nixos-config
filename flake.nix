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

        claude-code.url = "github:sadjow/claude-code-nix";

        hyprland.url = "github:hyprwm/hyprland";
        ags.url = "github:aylur/ags";
        astal.url = "github:aylur/astal";
        vimconf.url = "github:steven-na/nixos-nvim-config";
        nixcord.url = "github:kaylorben/nixcord";
        themecord = {
            url = "github:danihek/themecord";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            self,
            nixpkgs,
            home-manager,
            claude-code,
            ...
        }@inputs:
        {
            nixosConfigurations.bcnix = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    {
                        nixpkgs.overlays = [
                            inputs.nur.overlays.default
                            claude-code.overlays.default
                        ];
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
