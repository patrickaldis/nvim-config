pkgs: pins:
  let
  # packages
  direnv-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "direnv-nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "NotAShelf";
      repo = "direnv.nvim";
      rev = "4dfc8758a1deab45e37b7f3661e0fd3759d85788";
      hash = "sha256-KqO8uDbVy4sVVZ6mHikuO+SWCzWr97ZuFRC8npOPJIE=";
    };
  };
  readline-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "readline-nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "hiberabyss";
      repo = "readline.nvim";
      rev = "bce06a4d8b9761f507e109fad7666ad87bb8bcac";
      hash = "sha256-Ebu8nM8OZXcT36/5/1bBvB/NyzVKYVQh0i55PNYcoSI=";
    };
    doCheck = false;
  };
  lualine-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "lualine.nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-lualine";
      repo = "lualine.nvim";
      rev = "47f91c416daef12db467145e16bed5bbfe00add8";
      hash = "sha256-OpLZH+sL5cj2rcP5/T+jDOnuxd1QWLHCt2RzloffZOA=";
    };
  };
  opencode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "opencode.nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "nickjvandyke";
      repo = "opencode.nvim";
      rev = "e876696dc93c1962eaeff8ca5114c23c20485d09";
      hash = "sha256-ShAot7XV5IgXIeb6FDo8Md4Y3KFHzNEaKOM2k7tXvxs=";
    };
  };
  workspace-diagnostics = pkgs.vimUtils.buildVimPlugin {
    pname = "workspace-diagnostics";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "artemave";
      repo = "workspace-diagnostics.nvim";
      rev = "a35321d8401878cc9558e357acfd0da58b582739";
      hash = "sha256-xVZYcOw+n/6+4aW+7pcngTTQUBbGsO+QjcHXf3GtaFs=";
    };
  };
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
