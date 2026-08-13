{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = inputs : let
    system = "x86_64-linux";
    pkgs = import inputs.nixpkgs {
      inherit system;
    };
  in
  {
  packages.${system}.default =
    pkgs.neovim.override {
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
