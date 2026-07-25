return {
  -- Desativa mason (NixOS: servidores instalados via nix)
  { "mason-org/mason.nvim",           opts = { ensure_installed = {} } },
  { "mason-org/mason-lspconfig.nvim", opts = { ensure_installed = {} } },

  -- Treesitter: usa o tree-sitter CLI do sistema (instalado via nix)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c", "cpp", "lua", "nix", "typescript", "javascript",
        "tsx", "vue", "html", "css", "json", "bash", "markdown",
      },
    },
  },

  -- LSP: todos instalados via nix, não pelo mason
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls   = { mason = false },
        vue_ls  = { mason = false },
        lua_ls  = { mason = false },
        nixd    = { mason = false },
        clangd  = { mason = false },
        eslint  = { mason = false },
      },
    },
  },
}
