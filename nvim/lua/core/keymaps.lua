local map = vim.keymap.set
local opts = { noremap = true, silent = true }

----------------------------------------------------------------
-- ОКНА / СПЛИТЫ
----------------------------------------------------------------
-- Перемещение между окнами
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Размеры сплитов
map("n", "<A-=>", ":vertical resize +5<CR>", opts)
map("n", "<A-->", ":vertical resize -5<CR>", opts)
map("n", "<A-]>", ":resize +2<CR>", opts)
map("n", "<A-[>", ":resize -2<CR>", opts)

----------------------------------------------------------------
-- БУФЕРЫ / ТАБЫ
----------------------------------------------------------------
-- Буферы через bufferline (будут показываться как вкладки)
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", opts)
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", opts)

----------------------------------------------------------------
-- ТЕРМИНАЛ (toggleterm)
----------------------------------------------------------------
-- Открыть/закрыть терминал
map("n", "<C-p>", "<cmd>ToggleTerm<CR>", opts)
-- Из терминала по Ctrl+t выходим и закрываем
map("t", "<C-p>", "<C-\\><C-n><cmd>ToggleTerm<CR>", opts)

-- Навигация по окнам из терминала
map("t", "<C-h>", "<C-\\><C-n><C-w>h", opts)
map("t", "<C-j>", "<C-\\><C-n><C-w>j", opts)
map("t", "<C-k>", "<C-\\><C-n><C-w>k", opts)
map("t", "<C-l>", "<C-\\><C-n><C-w>l", opts)

----------------------------------------------------------------
-- Навигация по диагностике (ошибкам/варнингам)
----------------------------------------------------------------
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Следующая / предыдущая проблема
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "[d", vim.diagnostic.goto_prev, opts)

-- Показать окно с текстом ошибки под курсором
map("n", "gl", vim.diagnostic.open_float, opts)

-- Список всех диагностик в текущем буфере в quickfix-окне
map("n", "<leader>d", vim.diagnostic.setloclist, opts)

