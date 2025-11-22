return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'j-hui/fidget.nvim',
    opts = {},
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'saghen/blink.cmp',
      'folke/lazydev.nvim',
      'j-hui/fidget.nvim',
    },
    config = function()
      -- Автокоманда при подключении LSP
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
          end

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Capabilities для completion
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Безопасное получение lspconfig с обработкой ошибок
      local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
      if not lspconfig_ok then
        vim.notify('nvim-lspconfig not found', vim.log.levels.ERROR)
        return
      end

      -- Настройка LSP серверов (установлены через Nix)
      local servers = {
        nil_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
        ts_ls = {},
        pyright = {},
        html = {},
        cssls = {},
        jsonls = {},
        bashls = {},
      }

      -- Настраиваем каждый сервер
      for server_name, config in pairs(servers) do
        if lspconfig[server_name] then
          config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
          lspconfig[server_name].setup(config)
        end
      end
    end,
  },
}
