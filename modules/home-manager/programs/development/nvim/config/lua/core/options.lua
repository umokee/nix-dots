-- [[ Setting options ]]
-- See `:help vim.o`

-- Номера строк
vim.o.number = true
vim.o.relativenumber = true

-- Мышь
vim.o.mouse = 'a'

-- Не показывать режим (уже в statusline)
vim.o.showmode = false

-- Синхронизация буфера обмена с ОС
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Break indent
vim.o.breakindent = true

-- История отмен
vim.o.undofile = true

-- Поиск без учета регистра
vim.o.ignorecase = true
vim.o.smartcase = true

-- Signcolumn
vim.o.signcolumn = 'yes'

-- Время обновления
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Разделение окон
vim.o.splitright = true
vim.o.splitbelow = true

-- Отображение пробельных символов
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Live preview замен
vim.o.inccommand = 'split'

-- Подсветка текущей строки
vim.o.cursorline = true

-- Минимальное число строк сверху/снизу от курсора
vim.o.scrolloff = 10

-- Диалог при несохраненных изменениях
vim.o.confirm = true
