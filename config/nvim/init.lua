-- ===================================================================
-- CTF PWN 优化 Neovim 配置 (修复与优化版本)
-- ===================================================================

-- 确保 packer 自动安装
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- 使用 Lua 配置插件
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- ===============================
  -- 基础插件
  -- ===============================
  use 'tpope/vim-fugitive'        -- Git 集成
  use 'tpope/vim-commentary'      -- 快速注释 gcc
  use 'tpope/vim-surround'        -- 快速修改包围符号

  -- ===============================
  -- 文件管理和搜索
  -- ===============================
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use 'nvim-tree/nvim-tree.lua'   -- 文件树
  use 'nvim-tree/nvim-web-devicons' -- 图标支持

  -- ===============================
  -- LSP 和补全
  -- ===============================
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'

  -- ===============================
  -- PWN 特化插件
  -- ===============================
  use 'fidian/hexmode'            -- 十六进制模式切换 (移除冗余的 hexman.vim 以避免冲突)

  -- ===============================
  -- 语法高亮和主题
  -- ===============================
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'  -- 更新为推荐的 TSUpdate 命令 (移除弃用的 with_sync)
  }
  use 'morhetz/gruvbox'           -- 护眼主题
  use 'folke/tokyonight.nvim'     -- 现代主题

  -- ===============================
  -- 状态栏和界面
  -- ===============================
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }
  use {
    'akinsho/bufferline.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' }
  }  -- 添加 web-devicons 依赖

  -- ===============================
  -- 调试支持
  -- ===============================
  use 'mfussenegger/nvim-dap'
  use {
    'rcarriga/nvim-dap-ui',
    requires = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' }  -- 添加 nvim-nio 依赖以修复 dap-ui 问题
  }
  use 'mfussenegger/nvim-dap-python'

  -- ===============================
  -- 终端集成
  -- ===============================
  use 'akinsho/toggleterm.nvim'

  -- 自动同步插件（首次安装后）
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-----------------------------------------------------------
-- 基础设置
-----------------------------------------------------------
local opt = vim.opt

-- 行号和界面
opt.number = true
opt.relativenumber = true       -- 相对行号，方便跳转
opt.cursorline = true           -- 高亮当前行
opt.colorcolumn = "80"          -- 80列提示线

-- 缩进设置（适合Python和汇编）
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true

-- 搜索设置
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- 文件处理
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true             -- 持久化撤销

-- 界面优化
opt.wrap = false                -- 不自动换行
opt.scrolloff = 8               -- 保持8行可见
opt.sidescrolloff = 8
opt.signcolumn = "yes"          -- 始终显示符号列
opt.termguicolors = true        -- 真彩色支持

-- 分割窗口
opt.splitbelow = true
opt.splitright = true

-- 鼠标支持
opt.mouse = "a"

-- 剪贴板
opt.clipboard = "unnamedplus"

-----------------------------------------------------------
-- 主题配置
-----------------------------------------------------------
-- 设置主题（可选gruvbox或tokyonight）
vim.cmd([[
  try
    colorscheme gruvbox
    set background=dark
  catch
    colorscheme default
  endtry
]])

-----------------------------------------------------------
-- 键位映射 (适合PWN工作流)
-----------------------------------------------------------
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader 键
vim.g.mapleader = " "

-- 快速保存和退出
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)
keymap("n", "<leader>x", ":x<CR>", opts)

-- 窗口管理
keymap("n", "<leader>sv", ":vsplit<CR>", opts)     -- 垂直分割
keymap("n", "<leader>sh", ":split<CR>", opts)      -- 水平分割
keymap("n", "<C-h>", "<C-w>h", opts)               -- 左窗口
keymap("n", "<C-j>", "<C-w>j", opts)               -- 下窗口
keymap("n", "<C-k>", "<C-w>k", opts)               -- 上窗口
keymap("n", "<C-l>", "<C-w>l", opts)               -- 右窗口

-- Buffer 管理
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprev<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)

-- 文件树
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope 搜索
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)

-- 终端
keymap("n", "<leader>tt", ":ToggleTerm<CR>", opts)
keymap("t", "<Esc>", "<C-\\><C-n>", opts)          -- 终端模式退出

-- PWN 特定功能
keymap("n", "<leader>hx", ":Hexmode<CR>", opts)    -- 十六进制模式
keymap("n", "<leader>py", ":!python3 %<CR>", opts) -- 运行Python
keymap("n", "<leader>gdb", ":TermExec cmd='gdb %:r'<CR>", opts) -- 启动GDB

-- 快速编辑常见文件类型模板
keymap("n", "<leader>pe", ":e exploit.py<CR>", opts)
keymap("n", "<leader>ps", ":e solve.py<CR>", opts)

-----------------------------------------------------------
-- 补全设置 (nvim-cmp)
-----------------------------------------------------------
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- 命令行补全
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-----------------------------------------------------------
-- LSP 配置
-----------------------------------------------------------
local lspconfig = require('lspconfig')

-- LSP 按键映射
local on_attach = function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  keymap('n', 'gD', vim.lsp.buf.declaration, bufopts)
  keymap('n', 'gd', vim.lsp.buf.definition, bufopts)
  keymap('n', 'K', vim.lsp.buf.hover, bufopts)
  keymap('n', 'gi', vim.lsp.buf.implementation, bufopts)
  keymap('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  keymap('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  keymap('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  keymap('n', 'gr', vim.lsp.buf.references, bufopts)
  keymap('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  
  -- 移除 print 以避免控制台杂乱 (优化)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Python LSP
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        diagnosticMode = "workspace",
      }
    }
  }
}

-- C/C++ LSP (clangd)
lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-----------------------------------------------------------
-- 插件配置
-----------------------------------------------------------

-- NvimTree
require("nvim-tree").setup({
  sort = { sorter = "case_sensitive" },  -- 更新为新 API (sort_by 已弃用)
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,  -- 显示隐藏文件
  },
})

-- Lualine 状态栏
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
}

-- Bufferline
require("bufferline").setup {}

-- ToggleTerm
require("toggleterm").setup {
  size = 15,
  open_mapping = [[<c-\>]],
  hide_numbers = true,
  direction = 'horizontal',
  shell = vim.o.shell,
}

-- Treesitter
require 'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "python", "lua", "vim", "bash" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
}

-- DAP 配置 (添加基本配置以使调试可用)
require("dapui").setup()
require("dap-python").setup("python")  -- 假设使用系统 Python

local dap = require("dap")
dap.listeners.after.event_initialized["dapui_config"] = function()
  require("dapui").open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  require("dapui").close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  require("dapui").close()
end

-- 添加 DAP 快捷键 (优化)
keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", opts)
keymap("n", "<leader>dc", ":DapContinue<CR>", opts)
keymap("n", "<leader>di", ":DapStepInto<CR>", opts)
keymap("n", "<leader>do", ":DapStepOver<CR>", opts)
keymap("n", "<leader>du", ":DapStepOut<CR>", opts)
keymap("n", "<leader>dt", ":DapTerminate<CR>", opts)

-----------------------------------------------------------
-- PWN 特定设置和自动命令
-----------------------------------------------------------

-- 自动命令组
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- PWN 文件类型检测和设置
local pwn_group = augroup("PwnFiles", { clear = true })
autocmd({ "BufNewFile", "BufRead" }, {
  group = pwn_group,
  pattern = { "*.asm", "*.s" },
  command = "set filetype=asm | set syntax=nasm"  -- 修复为正确的命令格式
})

autocmd({ "BufNewFile", "BufRead" }, {
  group = pwn_group,
  pattern = { "exploit.py", "solve.py", "pwn_*" },
  callback = function()
    -- PWN Python 文件模板
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "#!/usr/bin/env python3",
        "# -*- coding: utf-8 -*-",
        "",
        "from pwn import *",
        "",
        "# 设置目标",
        "# io = process('./target')",
        "# io = remote('host', port)",
        "",
        "# 设置架构和操作系统",
        "context.arch = 'amd64'",
        "context.os = 'linux'",
        "",
        "# 主要利用代码",
        "def exploit():",
        "    pass",
        "",
        "if __name__ == '__main__':",
        "    exploit()",
        ""
      })
    end
  end
})

-- 二进制文件自动以十六进制模式打开
autocmd({ "BufReadPost" }, {
  group = pwn_group,
  pattern = { "*.bin", "*.exe", "*.elf" },
  command = "Hexmode"
})

-- 保存时自动格式化 Python 代码 (检查 LSP 是否可用)
autocmd({ "BufWritePre" }, {
  group = pwn_group,
  pattern = { "*.py" },
  callback = function()
    if vim.lsp.buf_get_clients(0) ~= nil then
      vim.lsp.buf.format({ timeout_ms = 2000 })
    end
  end
})

-----------------------------------------------------------
-- PWN 实用函数
-----------------------------------------------------------

-- 快速启动 GDB 调试目标文件
function StartGDB()
  local file = vim.fn.expand("%:r")  -- 当前文件名（无扩展名）
  vim.cmd("TermExec cmd='gdb " .. file .. "'")
end

-- 快速运行 Python exploit
function RunExploit()
  local file = vim.fn.expand("%")
  vim.cmd("TermExec cmd='python3 " .. file .. "'")
end

-- 快速检查文件安全属性 (假设 checksec 命令可用)
function CheckSec()
  local file = vim.fn.expand("%:r")
  vim.cmd("TermExec cmd='checksec " .. file .. "'")
end

-- 绑定快捷键
keymap("n", "<leader>gd", ":lua StartGDB()<CR>", opts)
keymap("n", "<leader>re", ":lua RunExploit()<CR>", opts)
keymap("n", "<leader>cs", ":lua CheckSec()<CR>", opts)

print("🎯 CTF PWN Neovim 环境加载完成！(已修复与优化)")