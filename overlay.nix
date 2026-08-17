system: inputs: final: prev: {
  vimPlugins = prev.vimPlugins // {
    blink-pairs = inputs.blink-pairs.packages.${system}.default;
    inc-rename-nvim = prev.vimUtils.buildVimPlugin {
        pname = "inc-rename-nvim";
        version = "unstable";
        src = inputs.inc-rename-nvim;
    };
    multiple-cursors-nvim = prev.vimUtils.buildVimPlugin {
      pname = "multiple-cursors-nvim";
      version = "unstable";
      src = inputs.multiple-cursors-nvim;
    };
    render-markdown-nvim = prev.vimUtils.buildVimPlugin {
      pname = "render-markdown-nvim";
      version = "unstable";
      src = inputs.render-markdown-nvim;
    };
    log-highlight-nvim = prev.vimUtils.buildVimPlugin {
      pname = "log-highlight-nvim";
      version = "unstable";
      src = inputs.log-highlight-nvim;
    };
    workspace-diagnostics = prev.vimUtils.buildVimPlugin {
      pname = "workspace-diagnostics";
      version = "unstable";
      src = inputs.workspace-diagnostics;
    };
    opencode-nvim = prev.vimUtils.buildVimPlugin {
      pname = "opencode.nvim";
      version = "unstable";
      src = inputs.opencode-nvim;
    };
    readline-nvim = prev.vimUtils.buildVimPlugin {
      pname = "readline-nvim";
      version = "unstable";
      src = inputs.readline-nvim;
      doCheck = false;
    };
    direnv-nvim = prev.vimUtils.buildVimPlugin {
      pname = "direnv-nvim";
      version = "unstable";
      src = inputs.direnv-nvim;
    };
  };
}
