{
  inputs = {
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    blink-pairs.url = "github:saghen/blink.pairs";
    multiple-cursors-nvim = {
      url = "github:brenton-leighton/multiple-cursors.nvim";
      flake = false;
    };
    render-markdown-nvim = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };
    log-highlight-nvim = {
      url = "github:fei6409/log-highlight.nvim";
      flake = false;
    };
    workspace-diagnostics = {
      url = "github:artemave/workspace-diagnostics.nvim";
      flake = false;
    };
    opencode-nvim = {
      url = "github:nickjvandyke/opencode.nvim";
      flake = false;
    };
    readline-nvim = {
      url = "github:hiberabyss/readline.nvim";
      flake = false;
    };
    direnv-nvim = {
      url = "github:NotAShelf/direnv.nvim";
      flake = false;
    };
    inc-rename-nvim = {
      url = "github:smjonas/inc-rename.nvim";
      flake = false;
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.neovim-nightly.overlays.default
          (import ./overlay.nix system inputs)
        ];
      };
    in
    {
      packages.${system}.default = pkgs.wrapNeovimUnstable pkgs.neovim {
        autoconfigure = true;
        autowrapRuntimeDeps = true;
        plugins = [ (import ./config-plug pkgs) ];
      };
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.lua-language-server ];
      };
    };
}
