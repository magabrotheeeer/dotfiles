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

---------------------------------------------------------------------------
-- Основной список плагинов
---------------------------------------------------------------------------
require("lazy").setup({

    ---------------------------------------------------------------------------
    -- Иконки (для дерева, lualine, bufferline и т.п.)
    ---------------------------------------------------------------------------
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },

    ---------------------------------------------------------------------------
    -- Тема Ayu Dark
    ---------------------------------------------------------------------------
    {
        "Shatur/neovim-ayu",
        priority = 1000,
        config = function()
            require("ayu").setup({
                mirage = false, -- false => ayu-dark
            })
            vim.cmd("colorscheme ayu-dark")
        end,
    },

    ---------------------------------------------------------------------------
    -- LSP + Mason (gopls, pyright) + хоткеи LSP
    ---------------------------------------------------------------------------
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            require("mason").setup()

            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = cmp_lsp.default_capabilities()

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

            local base = {
                capabilities = capabilities,
                on_attach = on_attach,
            }

            -- Новый API Neovim 0.11+
            vim.lsp.config("gopls", base)
            vim.lsp.config("pyright", base)
            vim.lsp.config("clangd", base)
            vim.lsp.enable({ "gopls", "pyright", "clangd" })
        end,
    },

    ---------------------------------------------------------------------------
    -- nvim-cmp: автодополнение + Tab/Shift-Tab для выбора вариантов
    ---------------------------------------------------------------------------
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local cmp_types = require("cmp.types")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = {
                    autocomplete = {
                        cmp_types.cmp.TriggerEvent.TextChanged,
                    },
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<C-e>"]     = cmp.mapping.abort(),

                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
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
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "buffer" },
                }),
                window = {
                    completion    = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Telescope: fuzzy finder
    ---------------------------------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    layout_strategy = "flex",
                    sorting_strategy = "ascending",
                    prompt_prefix = "> ",
                },
            })

            local map = vim.keymap.set
            local opts = { noremap = true, silent = true }

            map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
            map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
            map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
            map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)
        end,
    },

    ---------------------------------------------------------------------------
    -- Дерево файлов (nvim-tree) С ИКОНКАМИ
    ---------------------------------------------------------------------------

{
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local api = require("nvim-tree.api")

    require("nvim-tree").setup({
      on_attach = function(bufnr)
        -- 1. Сначала загружаем ВСЕ стандартные keymaps nvim-tree
        api.config.mappings.default_on_attach(bufnr)

        -- 2. Затем твоё доп. поведение
        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        -- Открыть в табе
        vim.keymap.set("n", "<leader>t", api.node.open.tab, opts("Open in Tab"))

        -- Вертикальный split
        vim.keymap.set("n", "<leader>c", api.node.open.vertical, opts("Open Vertical Split"))

        -- Горизонтальный split
        vim.keymap.set("n", "<leader>s", api.node.open.horizontal, opts("Open Horizontal Split"))
      end,

      view = {
        width = 30,
      },
      renderer = {
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
        indent_markers = { enable = true },
        highlight_git = true,
      },
      git = {
        enable = true,
        ignore = false,
      },
      diagnostics = {
        enable = false,
      },
    })

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>",     { noremap = true, silent = true })
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
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Статус-лайн (lualine) с Ayu Dark и иконками
    ---------------------------------------------------------------------------
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    icons_enabled = true,
                    theme = "ayu_dark",
                    section_separators = "",
                    component_separators = "",
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },
                    lualine_c = { "filename" },
                    lualine_x = { "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Вкладки/буферы сверху (bufferline) с иконками
    ---------------------------------------------------------------------------
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "tabs",
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    diagnostics = "nvim_lsp",
                    separator_style = "thin",
                    always_show_bufferline = true,
                },
            })

            local map = vim.keymap.set
            local opts = { noremap = true, silent = true }
            map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", opts)
            map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", opts)
        end,
    },

    ---------------------------------------------------------------------------
    -- Встроенный терминал снизу (Ctrl+`)
    ---------------------------------------------------------------------------
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            local shell

            if vim.loop.os_uname().sysname == "Windows_NT" then
                local bash_path = "C:/Program Files/Git/bin/bash.exe"

                if vim.fn.filereadable(bash_path) == 1 then
                    shell = '"' .. bash_path .. '"'
                elseif vim.fn.executable("bash") == 1 then
                    shell = "bash"
                elseif vim.fn.executable("pwsh") == 1 then
                    shell = "pwsh"
                else
                    shell = "powershell.exe"
                end
            else
                shell = vim.o.shell
            end

            require("toggleterm").setup({
                shell = shell,
                direction = "horizontal",
                size = 15,
                shade_terminals = false,
                persist_mode = false,
                close_on_exit = true,
            })

            vim.keymap.set({ "n", "t" }, "<C-`>", function()
                require("toggleterm").toggle(1)
            end, { noremap = true, silent = true })
        end,
    },

    ---------------------------------------------------------------------------
    -- Автопаринг скобок/кавычек
    ---------------------------------------------------------------------------
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                fast_wrap = {},
                disable_filetype = { "TelescopePrompt", "vim" },
            })
        end,
    },

    ---------------------------------------------------------------------------
    -- Красивый список ошибок/предупреждений: Trouble
    ---------------------------------------------------------------------------
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({
                use_diagnostic_signs = true,
            })

            local map  = vim.keymap.set
            local opts = { noremap = true, silent = true }

            -- Диагностика текущего файла
            map("n", "<leader>xx", "<cmd>TroubleToggle document_diagnostics<CR>", opts)
            -- Диагностика по всему workspace
            map("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", opts)
        end,
    },

    ---------------------------------------------------------------------------
    -- Красивые уведомления: nvim-notify
    ---------------------------------------------------------------------------
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup({
                stages = "fade_in_slide_out",
                timeout = 2000,
                render = "compact",
            })
            vim.notify = require("notify")
        end,
    },

    ---------------------------------------------------------------------------
    -- Красивые pop-up'ы и LSP UI: noice.nvim
    ---------------------------------------------------------------------------
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    progress = { enabled = true },
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = true,
                },
            })
        end,
    },

})

---------------------------------------------------------------------------
-- Аккуратные diagnostics (LSP ошибки/варнинги)
---------------------------------------------------------------------------
-- Значки в колонке слева
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
        },
    },
})

-- Общие настройки diagnostics
vim.diagnostic.config({
    virtual_text = {
        prefix = "●",  -- маленькая точка перед текстом
        spacing = 2,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

-- Авто-попап ошибки под курсором при остановке
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})
