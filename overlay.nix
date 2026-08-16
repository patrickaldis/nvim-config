system:
inputs:
final:
prev:
{
    vimPlugins = prev.vimPlugins // {
        blink-pairs = inputs.blink-pairs.packages.${system}.default;
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
    };
}
