-- ===================================================================
-- CTF PWN 插件配置文件
-- 注意：这个文件现在不需要了，因为所有插件都在 init.lua 中配置
-- 但保留作为参考和备用
-- ===================================================================

return {
  -- ===============================
  -- 基础插件
  -- ===============================
  { 'tpope/vim-fugitive' },        -- Git 集成
  { 'tpope/vim-commentary' },      -- 快速注释
  { 'tpope/vim-surround' },        -- 包围符号操作
  
  -- ===============================
  -- 文件管理
  -- ===============================
  { 'nvim-tree/nvim-tree.lua' },
  { 'nvim-tree/nvim-web-devicons' },
  {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  },
  
  -- ===============================
  -- LSP 和补全系统
  -- ===============================
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-cmdline' },
  { 'L3MON4D3/LuaSnip' },
  { 'saadparwaiz1/cmp_luasnip' },
  
  -- ===============================
  -- PWN 和安全专用插件
  -- ===============================
  { 'vim-scripts/hexman.vim' },    -- 十六进制查看器
  { 'fidian/hexmode' },            -- 十六进制编辑模式
  
  -- ===============================
  -- 语法高亮和解析
  -- ===============================
  {"nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"},
  
  -- ===============================
  -- 调试支持
  -- ===============================
  { 'mfussenegger/nvim-dap' },
  { 'rcarriga/nvim-dap-ui' },
  { 'mfussenegger/nvim-dap-python' },
  
  -- ===============================
  -- 终端集成
  -- ===============================
  { 'akinsho/toggleterm.nvim' },
  
  -- ===============================
  -- 主题和UI
  -- ===============================
  { 'morhetz/gruvbox' },
  { 'folke/tokyonight.nvim' },
  { 'nvim-lualine/lualine.nvim' },
  { 'akinsho/bufferline.nvim' },
}