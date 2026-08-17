pkgs:
  let
  deps = with pkgs.vimPlugins; [

    # UI
    which-key-nvim

    lazygit-nvim
    nvim-tree-lua
    lualine-nvim
    nvim-web-devicons
    catppuccin-nvim
    nvim-hlslens
    marks-nvim
    tabby-nvim
    bufferline-nvim
    trouble-nvim
    workspace-diagnostics
    minimap-vim
    quicker-nvim
    multiple-cursors-nvim
    log-highlight-nvim

    # EDITOR
    readline-nvim
    direnv-nvim
    teamtype
    inc-rename-nvim
    diffview-nvim
    opencode-nvim
    render-markdown-nvim

    # COMPLETIONS
    blink-cmp
    blink-pairs
    luasnip

    # LSP
    nvim-lspconfig
    typst-preview-nvim

    # TREESITTER
    nvim-treesitter.withAllGrammars

    # FZF
    fzf-lua

    # MINI
    mini-nvim
  ];
  in
    pkgs.vimUtils.buildVimPlugin {
      pname = "config-plug";
      version = "0.1.0";

      src = ./src;
      doCheck = false;

      dependencies = deps;
      runtimeDeps = pkgs.lib.concatMap (p: p.runtimeDeps or []) deps;
    }
