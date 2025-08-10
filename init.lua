vim.cmd("let mapleader = '\\'")
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

-- folds
vim.cmd("set foldlevelstart=10")--   " open most folds by default
vim.cmd("set foldnestmax=10")--      " 10 nested fold max
vim.cmd("nnoremap <space> za")

vim.cmd("map <Leader>q :q<Esc>")
vim.cmd("map <Leader>w :w<Esc>")
vim.cmd("map <Leader>wq :wq<Esc>")


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


vim.keymap.set("n", "<C-B>", function()
  Snacks.picker.files {
    hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
  }
end, {})
vim.keymap.set("n", "<leader><space>", function()
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
