vim.cmd("let mapleader = '\\'")

-- Use Node v22 for LSP servers (pyright)
vim.env.PATH = "/home/ydeng/.nvm/versions/node/v22.22.1/bin:" .. vim.env.PATH

-- OSC 52 clipboard: allows yank to reach local clipboard over SSH/tmux
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

--
--
-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
-- require('fold_imports').setup()

vim.cmd("unmap \\")
vim.cmd("unmap \\|")


-- regular settings
vim.cmd("set showcmd")
vim.cmd("set lazyredraw")
vim.cmd("set wrap")
vim.cmd("set autoread") -- changes from outside vim
vim.cmd("set showmode") -- shows the current mode at the bottom of vim.
vim.cmd("set autoindent")  -- copies the indentation from the previous line.
vim.cmd("set showmode")    -- shows the current mode at the bottom of vim.
vim.cmd("set ttyfast")     -- tell vim that the terminal is fast.
vim.cmd("set backspace=indent,eol,start") -- this makes backspace work like normal
vim.cmd("set laststatus=2")    -- Shows current file in the status line.
vim.cmd("set hlsearch")
vim.cmd("set scrolloff=5") -- number of context lines before search result.
vim.cmd("set splitright")
vim.cmd("set colorcolumn=100")
vim.cmd("set shortmess+=c")
vim.cmd("set cmdheight=1")
vim.cmd("set statusline+=%F")
vim.cmd("set statusline=%F")

vim.cmd("nnoremap ,<space> :nohlsearch<cr>")

-- folds
vim.cmd("set foldlevelstart=10")--   " open most folds by default
vim.cmd("set foldnestmax=10")--      " 10 nested fold max
vim.cmd("set foldmethod=indent")
vim.cmd("nnoremap <space> za")


vim.cmd("map <Leader>q :q<Esc>")
vim.cmd("map <Leader>w :w<Esc>")
vim.cmd("map <Leader>wq :wq<Esc>")


-- toggle comment
vim.keymap.set("n", "<leader><leader>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<leader><leader>", "gc", { remap = true, desc = "Toggle comment block" })

-- quickfix navigation
vim.keymap.set("n", "<leader>xn", ":cnext<CR>", { silent = true, desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>xN", ":cprev<CR>", { silent = true, desc = "Prev quickfix item" })
vim.keymap.set("n", "<leader>xo", ":copen<CR>", { silent = true, desc = "Open quickfix list" })
vim.keymap.set("n", "<leader>xx", ":cclose<CR>", { silent = true, desc = "Close quickfix list" })

vim.keymap.set("n", "<leader>yy", function()
  vim.cmd("%y+")
  vim.notify("Copied entire file to clipboard")
end, { desc = "Copy entire file to clipboard" })

vim.keymap.set("n", "<leader>sr", function()
  Snacks.picker.resume()
end, { desc = "Resume last Snacks picker" })

vim.keymap.set("n", "grr", function()
  Snacks.picker.lsp_references({ include_declaration = true, include_current = true })
end, { desc = "Find references (Snacks picker)" })

vim.keymap.set("n", "<leader>ll", function()
  local enabled = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not enabled)
  vim.notify("Diagnostics " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<leader>?", function()
  local lines = {
    "  Custom Keybindings",
    "  ──────────────────",
    "  \\\\    Toggle comment (normal/visual)",
    "  \\gg    Copy GitHub link (normal/visual)",
    "  gd     Go to definition + highlight for n/N",
    "  gh     Jump back",
    "  gl     Jump forward",
    "  K      Hover info (LSP)",
    "  \\sr    Resume last Snacks picker",
    "  grr    Find references (Snacks picker)",
    "  *      Search word under cursor",
    "  cs\"'   Change surrounding \" to '",
    "  ds\"    Delete surrounding \"",
    "  ysiw)  Surround word with ()",
    "  mX/'X  Set/jump to mark X (A-Z = global)",
    "  \\xn    Next quickfix item",
    "  \\xN    Prev quickfix item",
    "  \\xo    Open quickfix list",
    "  \\xx    Close quickfix list",
    "  \\yy    Copy entire file to clipboard",
    "  \\ll    Toggle diagnostics",
    "  \\?     This help",
  }
  vim.api.nvim_echo(vim.tbl_map(function(l) return {l .. "\n"} end, lines), false, {})
end, { desc = "Show custom keybindings" })


-- gd: go to definition and set search pattern for n/N
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.keymap.set("n", "gd", function()
      local word = vim.fn.expand("<cword>")
      vim.fn.setreg("/", "\\<" .. word .. "\\>")
      vim.opt.hlsearch = true
      vim.lsp.buf.definition()
    end, { buffer = ev.buf, desc = "Go to definition + highlight word" })
  end,
})

-- jump list navigation
vim.keymap.set("n", "gh", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "gl", "<C-i>", { desc = "Jump forward" })

-- general movement
vim.cmd("nnoremap j gj")
vim.cmd("nnoremap k gk")
vim.cmd("inoremap kj <Esc>")
vim.cmd("inoremap jk <Esc>")
vim.cmd("set timeout timeoutlen=100")
vim.cmd("noremap j gj")
vim.cmd("noremap k gk")
vim.cmd("noremap E g$")
vim.cmd("noremap B g^")

vim.cmd("vmap > >gv")
vim.cmd("vmap < <gv")
vim.cmd("nmap <silent><C-j> <Esc>:m +1<Return>")
vim.cmd("nmap <silent><C-k> <Esc>:m -2<Return>")


-- backups and undos
vim.cmd("set backup")
vim.cmd("set undofile")
vim.cmd("set writebackup")
vim.cmd("set backupdir=/tmp")
vim.cmd("set directory=/tmp")
vim.cmd("set undodir=/tmp")
vim.cmd("set undodir=/tmp")

-- make scrolling move one line at a time
vim.cmd("map <ScrollWheelUp> <C-Y>")
vim.cmd("map <ScrollWheelDown> <C-E>")
vim.cmd("highlight Search  guibg=#56545f")

-- Background tint per devbox (matches iTerm2 profile chosen by the local
-- ssh wrapper). Re-applied on every ColorScheme so colorscheme changes
-- don't wipe it out. Local machine (no devbox match) keeps default.
local function devbox_background()
    local hostname = vim.fn.hostname()
    local bg
    if hostname:match("2404") then
        bg = "#002A15"  -- devboxydeng2404: green tint
    elseif hostname:match("devboxydeng") then
        bg = "#121a25"  -- devboxydeng: blue-gray tint
    end
    if bg then
        vim.api.nvim_set_hl(0, "Normal", { bg = bg })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = bg })
        vim.api.nvim_set_hl(0, "NonText", { bg = bg })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = bg })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
    end
end
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, { callback = devbox_background })

-- Copy GitHub link for current line
local function github_link(start_line, end_line)
  local file = vim.fn.expand("%:p")
  local repo_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " rev-parse --show-toplevel")[1]
  local relative = file:sub(#repo_root + 2)
  local branch = "master"
  local remote = vim.fn.systemlist("git -C " .. vim.fn.shellescape(repo_root) .. " remote get-url origin")[1]
  local org_repo = remote:match("github%.com[:/](.+)%.git$") or remote:match("github%.com[:/](.+)$")
  local url
  if end_line and start_line ~= end_line then
    url = string.format("https://github.com/%s/blob/%s/%s#L%d-L%d", org_repo, branch, relative, start_line, end_line)
  else
    url = string.format("https://github.com/%s/blob/%s/%s#L%d", org_repo, branch, relative, start_line)
  end
  vim.fn.setreg("+", url)
  vim.notify("Copied: " .. url)
end

vim.keymap.set("n", "<leader>gg", function()
  github_link(vim.fn.line("."))
end, { desc = "Copy GitHub link for current line" })

vim.keymap.set("v", "<leader>gg", function()
  local s = vim.fn.line("v")
  local e = vim.fn.line(".")
  if s > e then s, e = e, s end
  github_link(s, e)
end, { desc = "Copy GitHub link for selected lines" })

-- highlight trailing whitespace
-- this is awful for nvim homescreen so nevermind
-- vim.cmd("highlight ExtraWhitespace ctermbg=red guibg=red")
-- vim.cmd("match ExtraWhitespace /\\s\\+$/")

-- buffers
vim.cmd("noremap <C-L> :bnext<CR>")
vim.cmd("noremap <C-H> :bprevious<CR>")
vim.cmd("nnoremap ∆ <C-w>h")
vim.cmd("nnoremap ˙ <C-w>h")
vim.cmd("nnoremap ˚ <C-w>l")
vim.cmd("nnoremap ¬ <C-w>l")


Snacks.config.picker = {
  formatters = {
    file = {
      filename_first =false,   -- Show filename before path
      truncate = 1000,            -- Truncate path to this length
      filename_only = false,    -- Show only filename
      icon_width = 2,           -- Width of icons in characters
      git_status_hl = true,     -- Highlight by git status
    },
  },
  layout = {
    preset='telescope',
  }
}


-- workaround for shift-enter to open the picker
-- iterm2 must have shift-enter set to send text ✠
vim.keymap.set("n", "✠", function()
  Snacks.picker.files {
    hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
  }
end, {})


vim.keymap.set("n", "<leader><space>", function()
  vim.lsp.buf.format(require("astrolsp").format_opts) end, {}
)
vim.keymap.set("v", "<leader><space>", function()
  vim.lsp.buf.format(require("astrolsp").format_opts) end, {}
)


-- heirline stuff
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local colors = {
      bright_bg = utils.get_highlight("Folded").bg,
      bright_fg = utils.get_highlight("Folded").fg,
      red = utils.get_highlight("DiagnosticError").fg,
      dark_red = utils.get_highlight("DiffDelete").bg,
      green = utils.get_highlight("String").fg,
      blue = utils.get_highlight("Function").fg,
      gray = utils.get_highlight("NonText").fg,
      orange = utils.get_highlight("Constant").fg,
      purple = utils.get_highlight("Statement").fg,
      cyan = utils.get_highlight("Special").fg,
      diag_warn = utils.get_highlight("DiagnosticWarn").fg,
      diag_error = utils.get_highlight("DiagnosticError").fg,
      diag_hint = utils.get_highlight("DiagnosticHint").fg,
      diag_info = utils.get_highlight("DiagnosticInfo").fg,
      git_del = utils.get_highlight("diffDeleted").fg,
      git_add = utils.get_highlight("diffAdded").fg,
      git_change = utils.get_highlight("diffChanged").fg,
}

local Align = { provider = "%=" }
local Space = { provider = " " }

-- shows which mode we're on
local ViMode = {provider = function(self) return " " end, }
ViMode = utils.surround({}, function(self) return self:mode_color() end, {ViMode, hl = {fg = 'black'}} )
ViMode = utils.surround({ "", "" }, function(self) return self:mode_color() end, {ViMode, hl = {fg = 'black'}} )

local FileNameBlock = {
    -- let's first set up some attributes needed by this component and its children
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
    end,
}
-- We can now define some children separately and add them later

local FileIcon = {
    init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
        return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
        return { fg = self.icon_color }
    end
}

local FileName = {
    provider = function(self)
        -- first, trim the pattern relative to the current directory. For other
        -- options, see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ":p:r:s?/home/ydeng/ans/web/lib/??:s?/home/ydeng/??:gs?/?.?:s?web.lib.??")
        if filename == "" then return "[No Name]" end
        -- now, if the filename would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section below for dynamic truncation
        if not conditions.width_percent_below(#filename, 0.7) then
            filename = vim.fn.pathshorten(filename)
        end
        return filename
    end,
    hl = { fg = utils.get_highlight("Directory").fg },
}

local FileFlags = {
    {
        condition = function()
            return vim.bo.modified
        end,
        provider = " ",
        hl = { fg = "green" },
    },
    {
        condition = function()
            return not vim.bo.modifiable or vim.bo.readonly
        end,
        provider = "",
        hl = { fg = "orange" },
    },
}

-- Now, let's say that we want the filename color to change if the buffer is
-- modified. Of course, we could do that directly using the FileName.hl field,
-- but we'll see how easy it is to alter existing components using a "modifier"
-- component

local FileNameModifer = {
    hl = function()
        if vim.bo.modified then
            -- use `force` because we need to override the child's hl foreground
            return { fg = "cyan", bold = true, force=true }
        end
    end,
}


-- let's add the children to our FileNameBlock component
FileNameBlock = utils.insert(FileNameBlock,
    FileIcon,
    utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
    { provider = '%<'} -- this means that the statusline is cut here when there's not enough space
)


-- We're getting minimalist here!
local Ruler = {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "%7(%l/%3L%):%2c %P",
}

-- I take no credits for this! 🦁
local ScrollBar ={
    static = {
        sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
    },
    provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = "yellow", bg = "bright_bg"},
}


local Git = {
    condition = conditions.is_git_repo,

    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    hl = { fg = "purple" },


    {   -- git branch name
        provider = function(self)
            return " " -- .. self.status_dict.head
        end,
        hl = { bold = true }
    },
}

  -- 2 1 1

local GitChanges = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
  end,
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return (" " .. count  .. " ")
    end, 
    hl = {fg = "git_add"}
  },
  { provider = function(self)
      local count = self.status_dict.changed or 0
      return (" " .. count.. " ")
    end, 
    hl = {fg = "git_change"}
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return (" " .. count)
    end, 
    hl = {fg = "red"}
  },

}


local Breadcrumbs = {
  provider = function()
    local ok, aerial = pcall(require, "aerial")
    if not ok then return "" end
    local data = aerial.get_location(true) or {}
    if #data == 0 then return "" end
    local result = "." .. data[1].name
    for i = 2, #data do
      result = result .. " > " .. data[i].name
    end
    return result
  end,
  hl = { fg = utils.get_highlight("Directory").fg },
}

-- Track whether pyright has sent its first batch of diagnostics
vim.g.pyright_ready = false

-- Filter asynq diagnostics at the source and track pyright readiness
local original_publish = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == "pyright" then
    vim.g.pyright_ready = true
    result.diagnostics = vim.tbl_filter(function(d)
      if not d.message then return true end
      return not (d.message:match("Generator") or d.message:match("asynq") or d.message:match("l0cache"))
    end, result.diagnostics)
  end
  return original_publish(err, result, ctx, config)
end

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "pyright" then
      vim.g.pyright_ready = false
    end
  end,
})

local PyrightStatus = {
  provider = function()
    local clients = vim.lsp.get_clients({ bufnr = 0, name = "pyright" })
    if #clients == 0 then return "" end
    if vim.g.pyright_ready then return " 󰄭" end
    return " ..."
  end,
  hl = function()
    if vim.g.pyright_ready then
      return { fg = "green" }
    end
    return { fg = "orange" }
  end,
}

local ram_cache = { text = "", last_update = 0 }
local RamUsage = {
  provider = function()
    local now = os.time()
    if now - ram_cache.last_update < 5 then return ram_cache.text end
    local f = io.open("/proc/meminfo", "r")
    if not f then return "" end
    local total, available
    for line in f:lines() do
      if line:match("^MemTotal:") then
        total = tonumber(line:match("(%d+)"))
      elseif line:match("^MemAvailable:") then
        available = tonumber(line:match("(%d+)"))
      end
      if total and available then break end
    end
    f:close()
    if not total or not available then return "" end
    local used_gb = (total - available) / 1024 / 1024
    ram_cache.text = string.format(" %.1fG", used_gb)
    ram_cache.last_update = now
    return ram_cache.text
  end,
  hl = { fg = "cyan" },
}

local DefaultStatusline = {
      ViMode, Space, --Git,
      Space, GitChanges, Space, PyrightStatus, Align, FileNameBlock, Breadcrumbs, FileFlags, Align,
      Ruler, Space, ScrollBar, Space, RamUsage, Space,
}


local StatusLines = {

      hl = function()
            if conditions.is_active() then
                  return "StatusLine"
              else
                return "StatusLineNC"
            end
      end,

      -- the first statusline with no condition, or which condition returns true is used.
  --     -- think of it as a switch case with breaks to stop fallthrough.
           fallthrough = false,
  static = {
        mode_colors_map = {
            n = "cyan",
            i = "green",
            v = "purple",
            V = "purple",
            ["\22"] = "purple",
            c = "orange",
            s = "red",
            S = "red",
            ["\19"] = "red",
            R = "orange",
            r = "orange",
            ["!"] = "cyan",
            t = "green",
        },
        mode_color = function(self)
            local mode = conditions.is_active() and vim.fn.mode() or "n"
            return self.mode_colors_map[mode]
        end,
    },

  DefaultStatusline,
}


require("heirline").setup({ statusline = StatusLines , opts = {
  colors=colors,
}})


vim.lsp.config('pylsp', {
  settings = {
    pylsp = {
      plugins = {
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        mccabe = { enabled = false },
      },
    },
  },
})

vim.lsp.config('pyright', {
  settings = {
    python = {
      pythonPath = "/home/ydeng/ans/venv3.12/bin/python3",
      analysis = {
        diagnosticSeverityOverrides = {
          reportPrivateImportUsage = "none",
        },
      },
    },
  },
})


require("mason-lspconfig").setup({
    ensure_installed = {},
    automatic_enable = {
        exclude = {
            "pylsp"
        }
    },
    automatic_installation = false,
})
require("scrollview").setup()
require('urlview').setup()

-- Re-attach aerial after :e so breadcrumbs don't disappear
-- Only runs when re-editing an already-loaded buffer, not on first open
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    if not vim.b[args.buf]._aerial_seen then
      vim.b[args.buf]._aerial_seen = true
      return
    end
    vim.schedule(function()
      local ok, backends = pcall(require, "aerial.backends")
      if not ok then return end
      local attach_ok, _ = pcall(backends.attach, args.buf, true)
      if not attach_ok then return end
      local backend = backends.get(args.buf)
      if backend then
        backend.fetch_symbols(args.buf)
      end
    end)
  end,
})

require('lazy').plugins()

local highlight = {
    "tabone",
    "tabtwo",
    "tabthree",
    "tabfour",
    "tabfive",
    "tabsix",
    "tabseven",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "tabone", { bg = "#333355" })
    vim.api.nvim_set_hl(0, "tabtwo", { bg = "#444466" })
    vim.api.nvim_set_hl(0, "tabthree", { bg = "#555588" })
    vim.api.nvim_set_hl(0, "tabfour", { bg = "#6666AA" })
    vim.api.nvim_set_hl(0, "tabfive", { bg = "#7777CC" })
    vim.api.nvim_set_hl(0, "tabsix", { bg = "#8888DD" })
    vim.api.nvim_set_hl(0, "tabseven", { bg = "#9999FF" })
end)

--local highlight = {
--    "CursorColumn",
--    "Whitespace",
--}

require("ibl").setup {
    indent = { highlight = highlight, char = " " },
    whitespace = {
        --highlight = highlight,
        remove_blankline_trail =false,
    },
    scope = { enabled =false},
}
