-- init.lua {{{
-- Neovim specific settings
vim.o.icm = 'split'
vim.o.cia = 'kind,abbr,menu'
vim.o.foldtext = 'v:lua.vim.treesitter.foldtext()'
vim.o.winborder = 'rounded'
vim.o.list = true
vim.o.listchars = 'tab:» ,lead:•,trail:•'
vim.o.exrc = true

-- Disable netrw's handling of directories
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

local wk = require('which-key')

vim.keymap.set("n", "<Esc>", function()
  local has_floats = false

  -- Get all open windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    -- If it’s a floating window, close it
    if config.relative ~= "" then
      has_floats = true
      vim.api.nvim_win_close(win, false)
    end
  end

  if not has_floats then
    vim.cmd("nohlsearch")
  end
end, { noremap = true, silent = true, desc = "Close all floating windows" })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argv = vim.fn.argv()
    if #argv == 1 and vim.fn.isdirectory(argv[1]) == 1 then
      vim.cmd("enew")           -- open an empty buffer
      vim.cmd("cd " .. argv[1]) -- change working directory
    end
  end
})

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
      -- defer centering slightly so it's applied after render
      vim.schedule(function()
        vim.cmd("normal! zz")
      end)
    end
  end,
})

vim.o.showmode = false

vim.fn.sign_define("DiagnosticSignError",
  { text = "", hl = "DiagnosticSignError", texthl = "DiagnosticSignError", culhl = "DiagnosticSignErrorLine" })
vim.fn.sign_define("DiagnosticSignWarn",
  { text = "", hl = "DiagnosticSignWarn", texthl = "DiagnosticSignWarn", culhl = "DiagnosticSignWarnLine" })
vim.fn.sign_define("DiagnosticSignInfo",
  { text = "", hl = "DiagnosticSignInfo", texthl = "DiagnosticSignInfo", culhl = "DiagnosticSignInfoLine" })
vim.fn.sign_define("DiagnosticSignHint",
  { text = "", hl = "DiagnosticSignHint", texthl = "DiagnosticSignHint", culhl = "DiagnosticSignHintLine" })

-- neovide options
if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h10"
  vim.keymap.set({ "n", "v" }, "<C-->", function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1 end)
  vim.keymap.set({ "n", "v" }, "<C-=>", function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1 end)
  vim.keymap.set({ "n", "v" }, "<C-0>", function() vim.g.neovide_scale_factor = 1 end)
  vim.keymap.set({ "n", "v" }, "<C-ScrollWheelUp>",
    function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1 end)
  vim.keymap.set({ "n", "v" }, "<C-ScrollWheelDown>",
    function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1 end)
end

vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

wk.add({
  { "<leader>w",  proxy = "<C-w>",                  group = "windows" },
  { "<leader>'",  ":term<CR>",                      desc = "Open terminal" },
  { "<leader>b",  group = "buffers" },
  { "<leader>bk", ":bd<CR>",                        desc = "kill buffer" },
  { "<leader>bn", ":enew<CR>",                      desc = "new buffer" },
  { "<leader>s",  group = "set" },
  { "<leader>sw", "set wrap<CR>",                   desc = "set wrap" },
  { "<leader>c",  group = "config" },
  { "<leader>co", ":e ~/.config/nvim/init.lua<CR>", desc = "open" },
})

vim.keymap.set("n", "{", "{", { noremap = true })
vim.keymap.set("n", "}", "}", { noremap = true })

vim.keymap.del("n", "grn")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grt")
vim.keymap.del({ "n", "x" }, "gra")

local float_width = 80

vim.opt.updatetime = 200

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    wk.add({
      {
        "<leader>k",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local params = vim.lsp.util.make_position_params(0, "utf-16")

          vim.lsp.buf_request_all(bufnr, "textDocument/hover", params, function(results)
            local contents = {}

            for _, res in pairs(results) do
              if res.result and res.result.contents then
                local lines = vim.lsp.util.convert_input_to_markdown_lines(res.result.contents)
                vim.list_extend(contents, lines)
              end
            end

            if vim.tbl_isempty(contents) then
              return
            end

            local text = table.concat(contents, "\n")

            -- Strip custom tags, even if they span multiple lines
            text = text:gsub("[ \t\r\n]+%* %* %*[ \t\r\n]+", "\n---\n")

            contents = vim.split(text, "\n", { plain = true })

            if vim.tbl_isempty(contents) then
              return
            end

            vim.lsp.util.open_floating_preview(contents, "markdown", {
              border = "rounded",
              focusable = true,
              max_width = float_width,
              max_height = 20,
            })
          end)
        end,
        buffer = ev.buf,
        desc = "LSP hover"
      },
      {
        "<leader>j",
        function()
          vim.diagnostic.open_float { max_width = float_width, scope = 'cursor' }
        end,
        buffer = ev.buf,
        desc = "Diagnostic float"
      },
    })
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/formatting') then
      wk.add({
        { '<leader>=', function() vim.lsp.buf.format({ bufnr = ev.buf }) end, mode = { 'n', 'v' }, buffer = ev.buf, desc = "Format with LSP" },
      })
    end
    require("workspace-diagnostics").populate_workspace_diagnostics(client, ev.buf)
    if client:supports_method("textDocument/codeLens") then
      local group = vim.api.nvim_create_augroup("HlsCodeLens:" .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        group = group,
        buffer = ev.buf,
        callback = function()
          -- On Neovim 0.10+, refresh() defaults to *all buffers* unless you pass bufnr
          vim.lsp.codelens.enable(true,{ bufnr = ev.buf })
        end,
      })
    end
  end,
})

-- LSP Configurations
vim.lsp.config.nix = {
  cmd = { "nixd", "--inlay-hints=true" },
  filetypes = { "nix" },
  settings = {
    nixd = {
      nixpkgs = {
        expr = "import <nixpkgs> { }",
      },
      root_markers = { "flake.nix", ".git" },
      formatting = {
        command = { "nixfmt" },
      },
    },
  }
}

local function haskell_cmd()
  -- Prefer wrapper if available, otherwise fall back.
  if vim.fn.executable("haskell-language-server-wrapper") == 1 then
    return { "haskell-language-server-wrapper", "--lsp" }
  end
  return { "haskell-language-server", "--lsp" }
end

vim.lsp.config.haskell = {
  cmd = function(dispatchers)
    local cmd = haskell_cmd()
    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { "haskell", "lhaskell", 'cabal' },
  settings = {
    haskell = {
      plugin = {
        importLens = { codeLensOn = true, globalOn = true },
        moduleName = { codeLensOn = true, globalOn = true },
        ["ghcide-type-lenses"] = {
          codeLensOn = true,
          config = { mode = "always" },
        },
      },
      cabalFormattingProvider = "cabalfmt",
      formattingProvider = "fourmolu",
      sessionLoading = "multipleComponents"
    }
  }
}

vim.lsp.config.lua = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      diagnostics = { globals = { 'vim', 'wk' }, },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
    },
  }
}

vim.lsp.config.rust_analyzer = {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        experimental = {
          enable = true
        }
      }
    }
  }
}

vim.lsp.enable({
  'haskell',
  'nix',
  'lua',
  'rust_analyzer',
  'tinymist',
  'texlab'
})
-- }}}
-- Loaded ~~ which-key.nvim ~~ [no config]

-- Loaded ~~ lazygit.nvim ~~ [config] {{{
vim.g.lazygit_use_neovim_remote = 0
wk.add({
  { "<leader>g",  group = "git" },
  { "<leader>gg", ":LazyGit<CR>",                  desc = "Open Lazygit" },
  { "<leader>gf", ":LazyGitFilterCurrentFile<CR>", desc = "Open Lazygit log (current file)" }
})
-- }}}

-- Loaded ~~ nvim-tree.lua ~~ [config] {{{
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup {
    update_focused_file = {enable = true},
    sync_root_with_cwd = true,
    disable_netrw = true,
    renderer = {
        highlight_git = "name",
        icons = {
            show = {
                git = false
            }
        },
        root_folder_label = ":t:s?$??"
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = false,
        severity = {
            min = vim.diagnostic.severity.WARNING,
            max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
    },
    git = {
        enable = true,
        show_on_open_dirs = false
    }
}

local tree = require('nvim-tree.api').tree

wk.add({
  { "<leader>p", function() tree.toggle({ find_file = true, path = vim.fn.getcwd() }) end, desc = "Toggle file tree" },
})

function _G.nvimtree_width()
  -- NvimTree exposes its view width
  local ok, view = pcall(require, "nvim-tree.view")
  if not ok then
    return 0
  end

  if view.is_visible() then
    return view.View.width or 0
  end

  return 0
end
-- }}}

-- Loaded ~~ lualine.nvim ~~ [config] {{{
vim.opt.shortmess:append("S")

require('lualine').setup {
    options = {
        ignore_focus = { "NvimTree" },
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16, -- ~60fps
            events = {
                'WinEnter',
                'BufEnter',
                'BufWritePost',
                'SessionLoadPost',
                'FileChangedShellPost',
                'VimResized',
                'Filetype',
                'CursorMoved',
                'CursorMovedI',
                'ModeChanged',
            },
        }
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },
        lualine_x = {
            { 'diagnostics',
                sources = { 'nvim_workspace_diagnostic' }
            } },
        lualine_y = { 'filetype' },
        lualine_z = { 'location' }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
-- }}}

-- Loaded ~~ nvim-web-devicons ~~ [no config]

-- Loaded ~~ catppuccin-nvim ~~ [config] {{{
require('catppuccin').setup({
  term_colors = true
})
vim.cmd.colorscheme("catppuccin-mocha")
-- }}}

-- Loaded ~~ nvim-hlslens ~~ [config] {{{
require('hlslens').setup()

local kopts = {noremap = true, silent = true}

vim.api.nvim_set_keymap('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts)
vim.api.nvim_set_keymap('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    kopts)
vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

vim.api.nvim_set_keymap('n', '<Leader>l', '<Cmd>noh<CR>', kopts)
-- }}}

-- -- Loaded ~~ noice.nvim ~~ [config] {{{
-- require("noice").setup({
--   cmdline = {
--     enabled = true, -- enables the Noice cmdline UI
--     view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
--     opts = {}, -- global options for the cmdline. See section on views
--     ---@type table<string, CmdlineFormat>
--     format = {
--       -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
--       -- view: (default is cmdline view)
--       -- opts: any options passed to the view
--       -- icon_hl_group: optional hl_group for the icon
--       -- title: set to anything or empty string to hide
--       cmdline = { pattern = "^:", icon = "", lang = "vim" },
--       search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
--       search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
--       filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
--       lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
--       help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
--       input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
--       -- lua = false, -- to disable a format, set to `false`
--     },
--   },
--   messages = {
--     -- NOTE: If you enable messages, then the cmdline is enabled automatically.
--     -- This is a current Neovim limitation.
--     enabled = true, -- enables the Noice messages UI
--     view = "notify", -- default view for messages
--     view_error = "notify", -- view for errors
--     view_warn = "notify", -- view for warnings
--     view_history = "messages", -- view for :messages
--     view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
--   },
--   popupmenu = {
--     enabled = true, -- enables the Noice popupmenu UI
--     ---@type 'nui'|'cmp'
--     backend = "nui", -- backend to use to show regular cmdline completions
--     ---@type NoicePopupmenuItemKind|false
--     -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
--     kind_icons = {}, -- set to `false` to disable icons
--   },
--   -- default options for require('noice').redirect
--   -- see the section on Command Redirection
--   ---@type NoiceRouteConfig
--   redirect = {
--     view = "popup",
--     filter = { event = "msg_show" },
--   },
--   -- You can add any custom commands below that will be available with `:Noice command`
--   ---@type table<string, NoiceCommand>
--   commands = {
--     history = {
--       -- options for the message history that you get with `:Noice`
--       view = "split",
--       opts = { enter = true, format = "details" },
--       filter = {
--         any = {
--           { event = "notify" },
--           { error = true },
--           { warning = true },
--           { event = "msg_show", kind = { "" } },
--           { event = "lsp", kind = "message" },
--         },
--       },
--     },
--     -- :Noice last
--     last = {
--       view = "popup",
--       opts = { enter = true, format = "details" },
--       filter = {
--         any = {
--           { event = "notify" },
--           { error = true },
--           { warning = true },
--           { event = "msg_show", kind = { "" } },
--           { event = "lsp", kind = "message" },
--         },
--       },
--       filter_opts = { count = 1 },
--     },
--     -- :Noice errors
--     errors = {
--       -- options for the message history that you get with `:Noice`
--       view = "popup",
--       opts = { enter = true, format = "details" },
--       filter = { error = true },
--       filter_opts = { reverse = true },
--     },
--     all = {
--       -- options for the message history that you get with `:Noice`
--       view = "split",
--       opts = { enter = true, format = "details" },
--       filter = {},
--     },
--   },
--   notify = {
--     -- Noice can be used as `vim.notify` so you can route any notification like other messages
--     -- Notification messages have their level and other properties set.
--     -- event is always "notify" and kind can be any log level as a string
--     -- The default routes will forward notifications to nvim-notify
--     -- Benefit of using Noice for this is the routing and consistent history view
--     enabled = true,
--     view = "notify",
--   },
--   lsp = {
--     progress = {
--       enabled = true,
--       -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
--       -- See the section on formatting for more details on how to customize.
--       --- @type NoiceFormat|string
--       format = "lsp_progress",
--       --- @type NoiceFormat|string
--       format_done = "lsp_progress_done",
--       throttle = 1000 / 30, -- frequency to update lsp progress message
--       view = "mini",
--     },
--     override = {
--       -- override the default lsp markdown formatter with Noice
--       ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
--       -- override the lsp markdown formatter with Noice
--       ["vim.lsp.util.stylize_markdown"] = false,
--       -- override cmp documentation with Noice (needs the other options to work)
--       ["cmp.entry.get_documentation"] = false,
--     },
--     hover = {
--       enabled = false,
--       silent = false, -- set to true to not show a message if hover is not available
--       view = nil, -- when nil, use defaults from documentation
--       ---@type NoiceViewOptions
--       opts = {}, -- merged with defaults from documentation
--     },
--     signature = {
--       enabled = true,
--       auto_open = {
--         enabled = true,
--         trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
--         luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
--         throttle = 50, -- Debounce lsp signature help request by 50ms
--       },
--       view = nil, -- when nil, use defaults from documentation
--       ---@type NoiceViewOptions
--       opts = {}, -- merged with defaults from documentation
--     },
--     message = {
--       -- Messages shown by lsp servers
--       enabled = false,
--       view = "notify",
--       opts = {},
--     },
--     -- defaults for hover and signature help
--     documentation = {
--       view = "hover",
--       ---@type NoiceViewOptions
--       opts = {
--         lang = "markdown",
--         replace = true,
--         render = "plain",
--         format = { "{message}" },
--         win_options = { concealcursor = "n", conceallevel = 3 },
--       },
--     },
--   },
--   markdown = {
--     hover = {
--       ["|(%S-)|"] = vim.cmd.help, -- vim help links
--       ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
--     },
--     highlights = {
--       ["|%S-|"] = "@text.reference",
--       ["@%S+"] = "@parameter",
--       ["^%s*(Parameters:)"] = "@text.title",
--       ["^%s*(Return:)"] = "@text.title",
--       ["^%s*(See also:)"] = "@text.title",
--       ["{%S-}"] = "@parameter",
--     },
--   },
--   health = {
--     checker = true, -- Disable if you don't want health checks to run
--   },
--   ---@type NoicePresets
--   presets = {
--     -- you can enable a preset by setting it to true, or a table that will override the preset config
--     -- you can also add custom presets that you can enable/disable with enabled=true
--     bottom_search = true, -- use a classic bottom cmdline for search
--     command_palette = false, -- position the cmdline and popupmenu together
--     long_message_to_split = false, -- long messages will be sent to a split
--     inc_rename = false, -- enables an input dialog for inc-rename.nvim
--     lsp_doc_border = true, -- add a border to hover docs and signature help
--   },
--   throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
--   ---@type NoiceConfigViews
--   views = {}, ---@see section on views
--   ---@type NoiceRouteConfig[]
--   routes = {}, --- @see section on routes
--   ---@type table<string, NoiceFilter>
--   status = {}, --- @see section on statusline components
--   ---@type NoiceFormatOptions
--   format = {}, --- @see section on formatting
-- })
--
-- vim.lsp.handlers["window/showMessage"] = require("noice.lsp.message").on_message
-- }}}

-- Loaded ~~ marks.nvim ~~ [config] {{{
require'marks'.setup {
  -- whether to map keybinds or not. default true
  default_mappings = false,
  -- which builtin marks to show. default {}
  builtin_marks = { ".", "<", ">", "^" },
  -- whether movements cycle back to the beginning/end of buffer. default true
  cyclic = true,
  -- whether the shada file is updated after modifying uppercase marks. default false
  force_write_shada = false,
  -- how often (in ms) to redraw signs/recompute mark positions. 
  -- higher values will have better performance but may cause visual lag, 
  -- while lower values may cause performance penalties. default 150.
  refresh_interval = 250,
  -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
  -- marks, and bookmarks.
  -- can be either a table with all/none of the keys, or a single number, in which case
  -- the priority applies to all marks.
  -- default 10.
  sign_priority = { lower=10, upper=15, builtin=8, bookmark=20 },
  -- disables mark tracking for specific filetypes. default {}
  excluded_filetypes = {},
  -- disables mark tracking for specific buftypes. default {}
  excluded_buftypes = { 'nofile' },
  -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
  -- sign/virttext. Bookmarks can be used to group together positions and quickly move
  -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
  -- default virt_text is "".
  bookmark_0 = {
    sign = "⚑",
    virt_text = "hello world",
    -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
    -- defaults to false.
    annotate = false,
  },
  mappings = {}
}
-- }}}

-- Loaded ~~ tabby.nvim ~~ [config] {{{
local theme = {
    fill = 'TabLineFill',
    -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
    head = 'TabLine',
    current_tab = 'TabLineSel',
    tab = 'TabLine',
    win = 'TabLine',
    tail = 'TabLine',
}
require("tabby").setup({
    line = function(line)
        return {
            {
                { '  ', hl = theme.head },
                line.sep('' .. string.rep(" ", nvimtree_width()), theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
                local hl = tab.is_current() and theme.current_tab or theme.tab
                return {
                    line.sep('', hl, theme.fill),
                    tab.is_current() and '' or '󰆣',
                    tab.number(),
                    tab.name(),
                    tab.close_btn(''),
                    line.sep('', hl, theme.fill),
                    hl = hl,
                    margin = ' ',
                }
            end),
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                return {
                    line.sep('', theme.win, theme.fill),
                    win.is_current() and '' or '',
                    win.buf_name(),
                    line.sep('', theme.win, theme.fill),
                    hl = theme.win,
                    margin = ' ',
                }
            end),
            {
                line.sep('', theme.tail, theme.fill),
                { '  ', hl = theme.tail },
            },
            hl = theme.fill,
        }
    end,
    -- option = {}, -- setup modules' option,
})
-- }}}

-- Loaded ~~ bufferline.nvim ~~ [config] {{{
require("bufferline").setup{}
-- }}}

-- Loaded ~~ trouble.nvim ~~ [config] {{{
require('trouble').setup{
  auto_close = false, -- auto close when there are no items
  auto_open = false, -- auto open when there are items
  auto_preview = false, -- automatically open preview when on an item
  auto_refresh = true, -- auto refresh when open
  auto_jump = false, -- auto jump to the item when there's only one
  focus = false, -- Focus the window when opened
  restore = true, -- restores the last location in the list when opening
  follow = true, -- Follow the current item
  indent_guides = true, -- show indent guides
  max_items = 200, -- limit number of items that can be displayed per section
  multiline = false, -- render multi-line messages
  pinned = false, -- When pinned, the opened trouble window will be bound to the current buffer
  warn_no_results = true, -- show a warning when there are no results
  open_no_results = false, -- open the trouble window when there are no results
  ---@type trouble.Window.opts
  win = {}, -- window options for the results window. Can be a split or a floating window.
  -- Window options for the preview window. Can be a split, floating window,
  -- or `main` to show the preview in the main editor window.
  ---@type trouble.Window.opts
  preview = {
    type = "main",
    -- when a buffer is not yet loaded, the preview window will be created
    -- in a scratch buffer with only syntax highlighting enabled.
    -- Set to false, if you want the preview to always be a real loaded buffer.
    scratch = true,
  },
  -- Throttle/Debounce settings. Should usually not be changed.
  ---@type table<string, number|{ms:number, debounce?:boolean}>
  throttle = {
    refresh = 20, -- fetches new data when needed
    update = 10, -- updates the window
    render = 10, -- renders the window
    follow = 100, -- follows the current item
    preview = { ms = 100, debounce = true }, -- shows the preview for the current item
  },
  -- Key mappings can be set to the name of a builtin action,
  -- or you can define your own custom action.
  ---@type table<string, trouble.Action.spec|false>
  keys = {
    ["?"] = "help",
    r = "refresh",
    R = "toggle_refresh",
    q = "close",
    o = "jump_close",
    ["<esc>"] = "cancel",
    ["<cr>"] = "jump",
    ["<2-leftmouse>"] = "jump",
    ["<c-s>"] = "jump_split",
    ["<c-v>"] = "jump_vsplit",
    -- go down to next item (accepts count)
    -- j = "next",
    ["}"] = "next",
    ["]]"] = "next",
    -- go up to prev item (accepts count)
    -- k = "prev",
    ["{"] = "prev",
    ["[["] = "prev",
    dd = "delete",
    d = { action = "delete", mode = "v" },
    i = "inspect",
    p = "preview",
    P = "toggle_preview",
    zo = "fold_open",
    zO = "fold_open_recursive",
    zc = "fold_close",
    zC = "fold_close_recursive",
    za = "fold_toggle",
    zA = "fold_toggle_recursive",
    zm = "fold_more",
    zM = "fold_close_all",
    zr = "fold_reduce",
    zR = "fold_open_all",
    zx = "fold_update",
    zX = "fold_update_all",
    zn = "fold_disable",
    zN = "fold_enable",
    zi = "fold_toggle_enable",
    gb = { -- example of a custom action that toggles the active view filter
      action = function(view)
        view:filter({ buf = 0 }, { toggle = true })
      end,
      desc = "Toggle Current Buffer Filter",
    },
    s = { -- example of a custom action that toggles the severity
      action = function(view)
        local f = view:get_filter("severity")
        local severity = ((f and f.filter.severity or 0) + 1) % 5
        view:filter({ severity = severity }, {
          id = "severity",
          template = "{hl:Title}Filter:{hl} {severity}",
          del = severity == 0,
        })
      end,
      desc = "Toggle Severity Filter",
    },
  },
  ---@type table<string, trouble.Mode>
  modes = {
    -- sources define their own modes, which you can use directly,
    -- or override like in the example below
    lsp_references = {
      -- some modes are configurable, see the source code for more details
      params = {
        include_declaration = true,
      },
    },
    -- The LSP base mode for:
    -- * lsp_definitions, lsp_references, lsp_implementations
    -- * lsp_type_definitions, lsp_declarations, lsp_command
    lsp_base = {
      params = {
        -- don't include the current location in the results
        include_current = false,
      },
    },
    -- more advanced example that extends the lsp_document_symbols
    symbols = {
      desc = "document symbols",
      mode = "lsp_document_symbols",
      focus = false,
      win = { position = "right" },
      filter = {
        -- remove Package since luals uses it for control flow structures
        ["not"] = { ft = "lua", kind = "Package" },
        any = {
          -- all symbol kinds for help / markdown files
          ft = { "help", "markdown" },
          -- default set of symbol kinds
          kind = {
            "Class",
            "Constructor",
            "Enum",
            "Field",
            "Function",
            "Interface",
            "Method",
            "Module",
            "Namespace",
            "Package",
            "Property",
            "Struct",
            "Trait",
          },
        },
      },
    },
  },
  icons = {
    ---@type trouble.Indent.symbols
    indent = {
      top           = "│ ",
      middle        = "├╴",
      last          = "└╴",
      -- last          = "-╴",
      -- last       = "╰╴", -- rounded
      fold_open     = " ",
      fold_closed   = " ",
      ws            = "  ",
    },
    folder_closed   = " ",
    folder_open     = " ",
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      String        = " ",
      Struct        = "󰆼 ",
      TypeParameter = " ",
      Variable      = "󰀫 ",
    },
  },
}

local trouble = require('trouble')

wk.add({
  { "<leader>d", function() trouble.toggle('diagnostics') end, desc = "Toggle diagnostics" },
})
-- }}}

-- Loaded ~~ workspace-diagnostics ~~ [config] {{{
require("workspace-diagnostics").setup({
  workspace_files = function()
    local git_prefix = vim.trim(vim.fn.system({ "git", "rev-parse", "--show-prefix" }))
    local workspace_files = vim.fn.split(vim.fn.system("git ls-files . | sed 's#^" .. git_prefix .. "##'"), "\n")
    return workspace_files
  end
})
-- }}}

-- Loaded ~~ minimap.vim ~~ [no config]

-- Loaded ~~ quicker.nvim ~~ [config] {{{
wk.add({
  { "<leader>q", function() require("quicker").toggle() end, desc = "Toggle quickfix" },
  -- { "<leader>l", function() require("quicker").toggle({ loclist = true }) end, desc = "Toggle loclist" },
})
require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})
-- }}}

-- Loaded ~~ multiple-cursors-nvim ~~ [config] {{{
require('multiple-cursors').setup({
})
-- }}}

-- Loaded ~~ log-highlight-nvim ~~ [no config]

-- Loaded ~~ readline-nvim ~~ [config] {{{
local readline = require 'readline'
vim.keymap.set('!', '<C-DEL>', readline.kill_word)
vim.keymap.set('!', '<C-BS>', readline.backward_kill_word)
-- }}}

-- Loaded ~~ direnv-nvim ~~ [config] {{{
require("direnv").setup({
    -- Whether to automatically load direnv when entering a directory with .envrc
    autoload_direnv = true,

    -- Statusline integration
    -- statusline = {
    --   -- Enable statusline component
    --   enabled = false,
    --   -- Icon to display in statusline
    --   icon = "󱚟",
    -- },

    -- Keyboard mappings
    keybindings = {
        allow = "<Leader>va",
        deny = "<Leader>vd",
        reload = "<Leader>vr",
        edit = "<Leader>ve",
    },

    -- Notification settings
    notifications = {
        -- Log level (vim.log.levels.INFO, ERROR, etc.)
        level = vim.log.levels.INFO,
        -- Don't show notifications during autoload
        silent_autoload = false,
    },
})
-- }}}

-- Loaded ~~ teamtype ~~ [no config]

-- Loaded ~~ inc-rename.nvim ~~ [config] {{{
require("inc_rename").setup()
wk.add({
  { "<leader>r", ":IncRename ", desc = "Incremental rename" },
})
-- }}}

-- Loaded ~~ diffview.nvim ~~ [no config]

-- Loaded ~~ opencode.nvim ~~ [config] {{{
wk.add({
  { "<leader>#", function() require("opencode").toggle() end, desc = "Toggle opencode" },
})
-- }}}

-- Loaded ~~ render-markdown-nvim ~~ [config] {{{
vim.lsp.config.markdown = {
  cmd = { "marksman" },
  filetypes = { "markdown" }
}

vim.lsp.enable('markdown')

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true

    local opts = { buffer = true, expr = true, silent = true }
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })
    vim.keymap.set("n", "0", "g0", { buffer = true, silent = true })
    vim.keymap.set("n", "$", "g$", { buffer = true, silent = true })
  end,
})

require('render-markdown').setup({
  render_modes = true,
  overrides = {
    buflisted = {},
    buftype = {
      nofile = {
        render_modes = true,
        anti_conceal = { enabled = false },
        code = {
          language_icon = false,
          language_name = false,
          language_info = false,
        },
      },
    },
    filetype = {},
  },
})
-- }}}

-- Loaded ~~ blink.cmp ~~ [config] {{{
require('blink.cmp').setup {
  keymap = { preset = 'super-tab' },

  appearance = {
    nerd_font_variant = 'mono'
  },

  snippets = {
    preset = 'luasnip'
  },

  completion = {
    ghost_text = { enabled = true },
    documentation = { auto_show = false },
    menu = {
      draw = {
        align_to = 'label'
      },
      border = 'none'
    }
  },

  sources = {
    default = function(ctx)
      local success, node = pcall(vim.treesitter.get_node)
      if success and node and node:type() == 'comment' then
        return {}
      elseif vim.bo.filetype == 'lua' then
        return { 'lsp', 'path' }
      elseif vim.bo.filetype == 'markdown' then
        return { 'lsp', 'snippets' }
      else
        return { 'lsp', 'path', 'snippets', 'buffer' }
      end
    end
  },

  fuzzy = { implementation = "prefer_rust_with_warning" }
}
-- }}}

-- Loaded ~~ luasnip ~~ [no config]

-- Loaded ~~ nvim-lspconfig ~~ [config] {{{
wk.add({
  { "<leader>l",  group = "LSP" },
  { "<leader>lr", ":LspRestart<CR>", desc = "Restart" },
  { "<leader>lk", ":LspStop<CR>",    desc = "Kill" },
  { "<leader>ls", ":LspStart<CR>",   desc = "Start" },
  {
    "<leader>ld",
    function()
      for _, client in ipairs(vim.lsp.buf_get_clients()) do
        require("workspace-diagnostics").populate_workspace_diagnostics(client, 0)
      end
    end,
    desc = "Start"
  },
})
-- }}}

-- Loaded ~~ typst-preview.nvim ~~ [config] {{{
require('typst-preview').setup({})
-- }}}

-- Loaded ~~ fzf-lua ~~ [config] {{{
local fzf = require('fzf-lua')

wk.add({
  mode = { "n", "v" },
  { "<leader>f",  fzf.files,     desc = "Find file" },
  { "<leader>bb", fzf.buffers,   desc = "Buffers" },
  { "<leader>t",  fzf.builtin,   desc = "Fzf-Lua builtins" },
  { "<leader>/",  fzf.live_grep, desc = "Project grep" },
  { "<leader>z",  fzf.zoxide,    desc = "zoxide" },
  { "<leader>:",  fzf.commands,  desc = "open commands" },
  { "<leader>sf", fzf.filetypes, desc = "set filetype" },
  { "<leader>lS", fzf.lsp_live_workspace_symbols, desc = "Workspace Symbols" },
})

vim.api.nvim_create_autocmd({ 'LspAttach' }, {
  callback = function()
    wk.add({
      { "<leader>a",  fzf.lsp_code_actions,           desc = "open commands" },
      { "gd",         fzf.lsp_definitions,            desc = "goto definition" },
      { "gr",         fzf.lsp_references,             desc = "goto references" }
    })
  end
})

-- }}}

-- -- Loaded ~~ nvim-treesitter ~~ [config] {{{
-- require 'nvim-treesitter.configs'.setup {
--     highlight = { enable = true, },
-- }
-- -- }}}
--
-- -- Loaded ~~ nvim-treesitter-context ~~ [config] {{{
-- require 'treesitter-context'.setup {
--     enable = false
-- }
-- wk.add({
--   { "<leader>c", "<cmd>TSContext toggle<cr>", desc = "Toggle TS Context" },
-- })
-- -- }}}
--
-- -- Loaded ~~ nvim-treesitter-textobjects ~~ [config] {{{
-- require 'nvim-treesitter.configs'.setup {
--     incremental_selection = {
--         enable = true,
--         keymaps = {
--             init_selection = "<M-o>",
--             scope_incremental = "<M-O>",
--             node_incremental = "<M-o>",
--             node_decremental = "<M-i>",
--         },
--     },
-- }
-- }}}

-- Loaded ~~ mini.nvim ~~ [config] {{{
require('mini.bracketed').setup()               -- unimpaired bindings with TS
require('mini.diff').setup(
    {
        view = {
            style = 'sign',
            signs = { add = '▒', change = '▒', delete = '▁' },
        },
    }
)
wk.add({
  { '<leader>gd', "<cmd>:lua MiniDiff.toggle_overlay()<cr>", desc = "Toggle Diff Overlay" },
})
require('mini.icons').setup()               -- minimal icons
-- }}}
