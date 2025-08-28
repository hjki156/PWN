-- 确保 packer 自动安装
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
  end
end

-- 安装 packer（如果还没有）
ensure_packer()

-- 使用 Lua 配置插件
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'  -- 包管理器
  require('plugins')             -- 加载你的插件列表
end)

-----------------------------------------------------------
-- 基础设置
-----------------------------------------------------------
vim.opt.number = true          -- 显示行号

-- 设置缩进为 2 个空格

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2 

vim.opt.smartindent = true     -- 智能缩进

-- 启用语法高亮
vim.opt.syntax = 'on'

-----------------------------------------------------------
-- 补全设置 (nvim-cmp)
-----------------------------------------------------------
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      -- 这里可以集成 luasnip，但我们先简化
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),  -- Ctrl+Space 触发补全
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- 回车确认
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },      -- 来自 LSP 的补全（如 pyright）
    { name = 'buffer' },        -- 当前文件中的词
    { name = 'path' },          -- 文件路径
  })
})

-- 如果没有补全项，回车直接插入
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-----------------------------------------------------------
-- 启用 Python 的 LSP (pyright)
-----------------------------------------------------------
local lspconfig = require('lspconfig')

lspconfig.pyright.setup {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        diagnosticMode = "workspace",
      }
    }
  },
  -- 启动时提示
  on_attach = function()
    print("✅ Python LSP (pyright) 已启动")
  end
}

-- 可选：F12 跳转到定义
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })