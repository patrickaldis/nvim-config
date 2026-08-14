{pkgs, ...}:
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
  render-markdown-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "render-markdown-nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "MeanderingProgrammer";
      repo = "render-markdown.nvim";
      rev = "e3c18ddd27a853f85a6f513a864cf4f2982b9f26";
      hash = "sha256-7O8V8XDYn4ITF9VfvV1OSkto+piIm/DpwtEe+vJcE2g=";
    };
  };
  workspace-diagnostics = pkgs.vimUtils.buildVimPlugin {
    pname = "workspace-diagnostics";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "artemave";
      repo = "workspace-diagnostics.nvim";
      rev = "60f9175b2501ae3f8b1aba9719c0df8827610c8e";
      hash = "sha256-jSpKaKnGyip/nzqU52ypWLgoCtvccYN+qb5jzlwAnd4=";
    };
  };
  multiple-cursors-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "multiple-cursors-nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "brenton-leighton";
      repo = "multiple-cursors.nvim";
      rev = "8d410c06fad32cc0e3849318e056b308fbaafede";
      hash = "sha256-LHk+0i2zlgT64jNdIsxrXznOASyc88drnV2m1OP9RFY=";
    };
  };
  log-highlight-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "log-highlight-nvim";
    version = "";
    src = pkgs.fetchFromGitHub {
      owner = "fei6409";
      repo = "log-highlight.nvim";
      rev = "ca88628f6dd3b9bb46f9a7401669e24cf7de47a4";
      hash = "sha256-s2GL6ddIA9wJI+K/irDtW7xvM/ms8it+04akr3ljJLA=";
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
    luasnip

    # LSP
    nvim-lspconfig
    typst-preview-nvim

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
