{
  inputs = {
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = inputs : let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs { 
      inherit system;
      overlays = [
        inputs.neovim-nightly.overlays.default
      ];
    };
  in
  {
  packages.${system}.default =
    pkgs.wrapNeovim pkgs.neovim {
      configure = {
        packages.config-plug = {
          start = [
            (import ./config-plug pkgs)
          ];
          opt = [];
        };
      };
    };
  };
}
