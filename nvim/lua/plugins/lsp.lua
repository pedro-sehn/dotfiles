return {
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "vtsls" },
      -- eslint is installed but off by default: repos with a stale legacy
      -- .eslintrc (no parser set) make the server report every TS file as
      -- "The keyword 'import' is reserved". Enable per project with
      -- `:lua vim.lsp.enable("eslint")` or in a project-local exrc.
      automatic_enable = { exclude = { "eslint" } },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      -- Diagnostics UI
      vim.diagnostic.config({
        virtual_text = { spacing = 2, prefix = "●" },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN] = "W",
            [vim.diagnostic.severity.INFO] = "I",
            [vim.diagnostic.severity.HINT] = "H",
          },
        },
      })

      -- eslint --fix on save
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "eslint" then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = args.buf,
              command = "LspEslintFixAll",
            })
          end
        end,
      })

      -- LSP / diagnostic keymaps
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc })
      end
      map("K", vim.lsp.buf.hover, "Hover docs")
      map("gi", vim.lsp.buf.implementation, "Go to implementation")
      map("gy", vim.lsp.buf.type_definition, "Go to type definition")
      map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
      map("<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("<leader>e", vim.diagnostic.open_float, "Show diagnostic")
      map("<leader>dl", "<cmd>Telescope diagnostics<CR>", "List diagnostics")
      map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
      map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
    end,
  },
}
