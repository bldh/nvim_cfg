-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- add gruvbox
  { "rebelot/kanagawa.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-dragon",
    },
  },

  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } },
    config = true,
  },

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = true,
        virtual_text = false,
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = false,
      },
      -- add any global capabilities here
      capabilities = {},
      -- Automatically format on save
      autoformat = true,
      -- Enable this to show formatters used in a notification
      -- Useful for debugging formatter issues
      format_notify = false,
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        pyright = {},
        jsonls = {},
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          ---@type LazyKeys[]
          -- keys = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function ()
      require("lsp_lines").setup()
    end,
  },

  -- use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" },


  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  {
    "rcarriga/nvim-notify",
    enabled = false,
  },
  {
    'NeogitOrg/neogit',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function ()
      require('neogit').setup()
    end,
  },
  {
    'anuvyklack/hydra.nvim',
    config = function()
      local Hydra = require("hydra")
      local gitsigns = require('gitsigns')

        local hint = [[
        _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
        _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full 
        ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
        ^
        ^ ^              _<Enter>_: Neogit              _q_: exit
        ]]
      Hydra({
        name = 'Git',
        hint = hint,
        config = {
            buffer = bufnr,
            color = 'red',
            invoke_on_body = true,
            hint = {
              border = 'rounded'
            },
            on_key = function() vim.wait(50) end,
            on_enter = function()
              vim.cmd 'mkview'
              vim.cmd 'silent! %foldopen!'
              gitsigns.toggle_signs(true)
              gitsigns.toggle_linehl(true)
            end,
            on_exit = function()
              local cursor_pos = vim.api.nvim_win_get_cursor(0)
              vim.cmd 'loadview'
              vim.api.nvim_win_set_cursor(0, cursor_pos)
              vim.cmd 'normal zv'
              gitsigns.toggle_signs(false)
              gitsigns.toggle_linehl(false)
              gitsigns.toggle_deleted(false)
            end,
        },
        mode = {'n','x'},
        body = '<leader>G',
        heads = {
            { 'J',
              function()
                  if vim.wo.diff then return ']c' end
                  vim.schedule(function() gitsigns.next_hunk() end)
                  return '<Ignore>'
              end,
              { expr = true, desc = 'next hunk' } },
            { 'K',
              function()
                  if vim.wo.diff then return '[c' end
                  vim.schedule(function() gitsigns.prev_hunk() end)
                  return '<Ignore>'
              end,
              { expr = true, desc = 'prev hunk' } },
            { 's',
              function()
                  local mode = vim.api.nvim_get_mode().mode:sub(1,1)
                  if mode == 'V' then -- visual-line mode
                    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
                    vim.api.nvim_feedkeys(esc, 'x', false) -- exit visual mode
                    vim.cmd("'<,'>Gitsigns stage_hunk")
                  else
                    vim.cmd("Gitsigns stage_hunk")
                  end
              end,
              { desc = 'stage hunk' } },
            { 'u', gitsigns.undo_stage_hunk, { desc = 'undo last stage' } },
            { 'S', gitsigns.stage_buffer, { desc = 'stage buffer' } },
            { 'p', gitsigns.preview_hunk, { desc = 'preview hunk' } },
            { 'd', gitsigns.toggle_deleted, { nowait = true, desc = 'toggle deleted' } },
            { 'b', gitsigns.blame_line, { desc = 'blame' } },
            { 'B', function() gitsigns.blame_line{ full = true } end, { desc = 'blame show full' } },
            { '/', gitsigns.show, { exit = true, desc = 'show base file' } }, -- show the base of the file
            { '<Enter>', function() vim.cmd('Neogit') end, { exit = true, desc = 'Neogit' } },
            { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
        }
      })
    end,
  },
}
