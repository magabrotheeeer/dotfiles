-- bootstrap lazy.nvim: установка и подключение менеджера плагинов
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Основной список плагинов
require("lazy").setup({
  ---------------------------------------------------------------------------
  -- LSP + Mason (gopls, pyright) + хоткеи LSP
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Mason отвечает только за установку бинарников LSP/форматтеров
      "williamboman/mason.nvim",
      -- Этот плагин даёт функцию cmp_nvim_lsp.default_capabilities()
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Инициализация Mason
      require("mason").setup()

      -- capabilities для LSP с учётом nvim-cmp
      local cmp_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_lsp.default_capabilities()

      -- Общий on_attach для всех LSP-серверов
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true })
        end

        -- Навигация по коду
        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gD", vim.lsp.buf.declaration)
        map("n", "gi", vim.lsp.buf.implementation)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "K",  vim.lsp.buf.hover)

        -- Рефакторинг / действия
        map("n", "<leader>rn", vim.lsp.buf.rename)
        map("n", "<leader>ca", vim.lsp.buf.code_action)

        -- Форматирование
        map("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end)

        -- Описание/сигнатура функции на Ctrl+k
        map("n", "<C-k>", vim.lsp.buf.signature_help)
        map("i", "<C-k>", vim.lsp.buf.signature_help)
      end

      -- Базовая конфигурация для всех серверов
      local base = {
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Новый API Neovim 0.11+: регистрируем конфиги серверов
      vim.lsp.config("gopls", base)
      vim.lsp.config("pyright", base)

      -- Включаем LSP для этих серверов
      vim.lsp.enable({ "gopls", "pyright" })
    end,
  },

  ---------------------------------------------------------------------------
  -- nvim-cmp: автодополнение + Tab/Shift-Tab для выбора вариантов
  ---------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",  -- грузить, когда заходим в insert-режим
    dependencies = {
      "hrsh7th/cmp-buffer", -- источник: слова из текущего буфера
      "hrsh7th/cmp-path",   -- источник: пути к файлам
      "L3MON4D3/LuaSnip",   -- движок сниппетов
      -- cmp-nvim-lsp подключается выше как зависимость LSP
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local cmp_types = require("cmp.types")

      cmp.setup({
        -- как разворачивать сниппеты (через LuaSnip)
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- когда автоматически показывать меню автодополнения
        completion = {
          autocomplete = {
            cmp_types.cmp.TriggerEvent.TextChanged, -- при изменении текста
          },
        },

        -- бинды внутри меню автодополнения
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),                 -- вручную открыть меню
          ["<CR>"]      = cmp.mapping.confirm({ select = true }), -- Enter: подтвердить текущий вариант
          ["<C-e>"]     = cmp.mapping.abort(),                    -- закрыть меню

          -- Tab: следующий вариант (или прыжок по сниппету, или обычный Tab)
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Shift-Tab: предыдущий вариант
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- источники данных для автодополнения
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- подсказки от LSP (gopls, pyright)
          { name = "path" },     -- пути к файлам
          { name = "buffer" },   -- слова из текущего буфера
        }),

        -- оформление окон completion/doc
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Telescope: fuzzy finder (поиск файлов, текста, буферов, хелпа)
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" }, -- необходимая библиотека
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "flex",
          sorting_strategy = "ascending",
          prompt_prefix = "> ", -- префикс в строке поиска
        },
      })

      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Поиск файлов по имени
      map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
      -- Поиск по содержимому файлов (через ripgrep)
      map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
      -- Список открытых буферов
      map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
      -- Поиск по :help
      map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
    end,
  },

  ---------------------------------------------------------------------------
  -- Дерево файлов (nvim-tree) без иконок, с Ctrl+n
  ---------------------------------------------------------------------------
{
  "nvim-tree/nvim-tree.lua",
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 30,
      },
      renderer = {
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = false,

            -- важно: включаем только git
            git = true,
          },
        },
        indent_markers = {
          enable = true,
        },
        highlight_git = true,  -- подсвечивать строку по git-статусу
      },
      git = {
        enable = true,
        ignore = false,         -- показывать и .gitignore'нутые файлы
      },
      diagnostics = {
        enable = false,
      },
    })

    -- бинды на toggle
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-n>",     "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
  end,
},

  ---------------------------------------------------------------------------
  -- Git-интеграция: знаки изменений в колонке слева
  ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "-" },
          topdelete    = { text = "-" },
          changedelete = { text = "~" },
        },
        -- тут можно позже добавить хоткеи для навигации по хункам
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Статус-лайн (lualine): минимализм, без иконок
  ---------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = false,
          theme = "auto",            -- цвета берутся из текущей схемы
          section_separators = "",
          component_separators = "",
        },
        sections = {
          lualine_a = { "mode" },    -- текущий режим (NORMAL/INSERT)
          lualine_b = { "branch" },  -- git-ветка
          lualine_c = { "filename" },-- имя файла
          lualine_x = { "filetype" },-- тип файла
          lualine_y = { "progress" },-- прогресс по файлу (xx%)
          lualine_z = { "location" },-- строка:столбец
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Вкладки/буферы сверху (bufferline) в режиме "tabs"
  ---------------------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "tabs",           -- показывать реальные вкладки (tabpages)
          show_buffer_close_icons = false,
          show_close_icon = false,
          diagnostics = "nvim_lsp",
          separator_style = "thin",
          always_show_bufferline = true,
        },
      })

      -- Переключение вкладок по Shift+h / Shift+l
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }
      map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", opts)
      map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", opts)

      -- Плюс остаются стандартные gt / gT (классический Vim для табов)
    end,
  },

  ---------------------------------------------------------------------------
  -- Встроенный терминал в float-окне (Ctrl+t)
  ---------------------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        direction = "float",      -- плавающее окно
        shade_terminals = false,  -- без затемнения
      })
      -- сами бинды на Ctrl+t ты уже прописал в core/keymaps.lua:
      --   Ctrl+t в normal  → открыть/закрыть терминал
      --   Ctrl+t в terminal → закрыть и вернуться в редактор
    end,
  },
})

