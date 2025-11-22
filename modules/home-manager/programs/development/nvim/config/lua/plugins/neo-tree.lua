return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  lazy = false,
  keys = {
    { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Toggle file explorer' },
    { '<leader>E', '<cmd>Neotree focus<CR>', desc = 'Focus file explorer' },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
