-- Set leader key
vim.g.mapleader = ' '

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 50
-- vim.opt.colorcolumn = '80'

-- Auto-change directory to the one provided as an argument
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local path = vim.fn.argv(0)
        if path ~= "" and vim.fn.isdirectory(path) == 1 then
            vim.cmd("cd " .. vim.fn.fnameescape(path))
        end
    end,
})

-- Bootstrap lazy.nvim plugin manager
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

-- Plugin configuration
require("lazy").setup({
    -- LSP Configuration
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
        },
    },

    -- Mason for managing LSP servers
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup()
        end
    },

    {
        'williamboman/mason-lspconfig.nvim',
        config = function()
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'clangd',        -- C/C++
                    'pyright',       -- Python
                    'jdtls',         -- Java
                    'rust_analyzer', -- Rust
                    'intelephense',  -- PHP
                    'lua_ls',        -- Lua
                },
                automatic_installation = true,
            })
        end
    },

    -- Completion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
    },

    -- Snippets
    {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp'
    },

    -- Treesitter for syntax highlighting
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { 'c', 'python', 'java', 'rust', 'php', 'lua', 'vim', 'vimdoc', 'query' },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    -- File explorer
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('nvim-tree').setup({
                disable_netrw = true,
                hijack_netrw = true,
                view = {
                    width = 30,
                    side = 'left',
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })
        end
    },

    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('telescope').setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-h>"] = "which_key"
                        }
                    }
                }
            })
        end
    },

    -- Status line
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'auto',
                    component_separators = '|',
                    section_separators = '',
                },
            })
        end
    },

    -- Git integration
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    },

    -- Formatting
    {
        'stevearc/conform.nvim',
        config = function()
            require('conform').setup({
                formatters_by_ft = {
                    python = { 'black' },
                    rust = { 'rustfmt' },
                    c = { 'clang-format' },
                    cpp = { 'clang-format' },
                    java = { 'google-java-format' },
                    php = { 'php-cs-fixer' },
                    lua = { 'stylua' },
                },
                format_on_save = {
                    timeout_ms = 500,
                    lsp_fallback = true,
                },
            })
        end
    },

    -- Which-key for keybinding help
    {
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup()
        end
    },

    -- Colorscheme
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'catppuccin'
        end
    },
})

-- LSP Configuration
local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Add additional capabilities supported by nvim-cmp
local capabilities = cmp_nvim_lsp.default_capabilities()

-- LSP on_attach function
local on_attach = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- LSP keybindings
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format { async = true }
    end, opts)
end

-- Configure LSP servers
local servers = {
    clangd = {
        cmd = { "clangd", "--background-index" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
    },
    pyright = {
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "workspace",
                    useLibraryCodeForTypes = true
                }
            }
        }
    },
    jdtls = {},
    rust_analyzer = {
        settings = {
            ['rust-analyzer'] = {
                diagnostics = {
                    enable = false,
                }
            }
        }
    },
    intelephense = {
        settings = {
            intelephense = {
                files = {
                    maxSize = 1000000,
                },
            },
        }
    },
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    },
}

for server, config in pairs(servers) do
    config.on_attach = on_attach
    config.capabilities = capabilities
    lspconfig[server].setup(config)
end

-- Completion setup
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Helper function to get the project root (directory containing .git)
function get_git_root()
    local path = vim.fn.expand('%:p:h')
    local result = vim.fn.system('git -C ' .. vim.fn.shellescape(path) .. ' rev-parse --show-toplevel 2>/dev/null')
    if vim.v.shell_error == 0 then
        return vim.fn.trim(result)
    end
    return path
end

-- Helper function to execute Git command and provide feedback
local function execute_git_command(cmd, success_msg, error_msg)
    local git_root = get_git_root()
    local full_cmd = 'git -C ' .. vim.fn.shellescape(git_root) .. ' ' .. cmd
    local output = vim.fn.system(full_cmd)
    if vim.v.shell_error == 0 then
        print(success_msg .. (output ~= "" and ": " .. output or ""))
    else
        print(error_msg .. ": " .. output)
    end
end

-- Helper function to get list of modified/untracked files from git status
local function get_git_files()
    local git_root = get_git_root()
    local output = vim.fn.system('git -C ' .. vim.fn.shellescape(git_root) .. ' status --short 2>/dev/null')
    if vim.v.shell_error ~= 0 then
        return {}
    end
    local files = {}
    for line in output:gmatch("[^\r\n]+") do
        -- Extract file path from git status --short (e.g., " M file.txt" or "?? file.txt")
        local file = line:match("^%s*%S+%s+(.+)$")
        if file then
            table.insert(files, file)
        end
    end
    return files
end

-- Function to check if in a Git repository
function is_git_repo()
    local result = vim.fn.system('git -C ' ..
        vim.fn.shellescape(get_git_root()) .. ' rev-parse --is-inside-work-tree 2>/dev/null')
    return vim.v.shell_error == 0
end

-- Function to get the current branch name
function get_current_branch()
    return vim.fn.trim(vim.fn.system('git -C ' .. vim.fn.shellescape(get_git_root()) .. ' rev-parse --abbrev-ref HEAD'))
end

-- Function to check if upstream is set for the current branch
function has_upstream()
    local branch = get_current_branch()
    local upstream = vim.fn.system('git -C ' ..
        vim.fn.shellescape(get_git_root()) .. ' rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null')
    return vim.v.shell_error == 0
end

-- Smart git push with upstream handling and feedback
function smart_git_push()
    print("Starting git push...")
    if not is_git_repo() then
        print("Not a git repository")
        return
    end
    local branch = get_current_branch()
    local cmd
    if has_upstream() then
        cmd = 'push'
    else
        cmd = 'push --set-upstream origin ' .. vim.fn.shellescape(branch)
    end
    execute_git_command(cmd, 'Git push successful', 'Git push failed')
end

-- Smart git pull with upstream and merge strategy
function smart_git_pull()
    print("Starting git pull...")
    if not is_git_repo() then
        print("Not a git repository")
        return
    end
    local branch = get_current_branch()
    local cmd
    if has_upstream() then
        cmd = 'pull --no-rebase --allow-unrelated-histories'
    else
        cmd = 'pull --no-rebase --allow-unrelated-histories --set-upstream origin ' .. vim.fn.shellescape(branch)
    end
    execute_git_command(cmd, 'Git pull successful', 'Git pull failed')
end

-- Function to add Git remote
function add_git_remote()
    local remote_name = vim.fn.input('Remote name (e.g., origin): ')
    if remote_name == '' then
        print("Remote name cannot be empty")
        return
    end
    local remote_url = vim.fn.input('Remote URL (e.g., https://github.com/user/repo.git): ')
    if remote_url == '' then
        print("Remote URL cannot be empty")
        return
    end
    execute_git_command('remote add ' .. vim.fn.shellescape(remote_name) .. ' ' .. vim.fn.shellescape(remote_url),
        'Added remote ' .. remote_name .. ' with URL ' .. remote_url,
        'Failed to add remote ' .. remote_name)
end

-- File operation keybindings
vim.keymap.set('n', '<leader>w', ':write<CR>', { noremap = true, silent = true, desc = "Write file" })
vim.keymap.set('n', '<leader>q', ':quit<CR>', { noremap = true, silent = true, desc = "Quit" })
vim.keymap.set('n', '<leader>wq', ':wq<CR>', { noremap = true, silent = true, desc = "Write and quit" })
vim.keymap.set('n', '<leader>qa', ':quitall<CR>', { noremap = true, silent = true, desc = "Quit all" })
vim.keymap.set('n', '<leader>q!', ':quit!<CR>', { noremap = true, silent = true, desc = "Quit without saving" })
vim.keymap.set('n', '<leader>wqa', ':wqa<CR>', { noremap = true, silent = true, desc = "Write all and quit" })
vim.keymap.set('n', '<leader>wa', ':wall<CR>', { noremap = true, silent = true, desc = "Write all buffers" })
vim.keymap.set('n', '<leader>nf', ':NewFile<CR>', { noremap = true, desc = "Create new file in Git root" })

-- Git keybindings
vim.keymap.set('n', '<leader>ga', function()
    execute_git_command('add .', 'Git add all successful', 'Git add all failed')
end, { noremap = true, desc = "Git add all files" })

vim.keymap.set('n', '<leader>gf', function()
    if not is_git_repo() then
        print("Not a git repository")
        return
    end
    local files = get_git_files()
    local current_file = vim.fn.expand('%:t')
    if current_file ~= '' and not vim.tbl_contains(files, current_file) then
        table.insert(files, current_file) -- Add current file if not in git status
    end
    if #files == 0 then
        print("No modified or untracked files found")
        if current_file ~= '' then
            execute_git_command('add ' .. vim.fn.shellescape(current_file), 'Git add ' .. current_file .. ' successful',
                'Git add ' .. current_file .. ' failed')
        else
            print("No file open to add")
        end
        return
    end
    vim.ui.select(files, {
        prompt = 'Select file to git add (default: ' .. (current_file ~= '' and current_file or 'none') .. '):',
        format_item = function(item)
            return item
        end,
    }, function(choice)
        if choice == nil then
            if current_file ~= '' then
                execute_git_command('add ' .. vim.fn.shellescape(current_file),
                    'Git add ' .. current_file .. ' successful', 'Git add ' .. current_file .. ' failed')
            else
                print("Git add aborted: No file selected")
            end
            return
        end
        execute_git_command('add ' .. vim.fn.shellescape(choice), 'Git add ' .. choice .. ' successful',
            'Git add ' .. choice .. ' failed')
    end)
end, { noremap = true, desc = "Git add specific file" })

vim.keymap.set('n', '<leader>gc', function()
    if not is_git_repo() then
        print("Not a git repository")
        return
    end
    vim.ui.input({ prompt = 'Commit message: ' }, function(input)
        if input == nil or input == '' then
            print("Commit aborted: No message provided")
            return
        end
        execute_git_command('commit -m ' .. vim.fn.shellescape(input), 'Git commit successful', 'Git commit failed')
    end)
end, { noremap = true, desc = "Git commit" })

vim.keymap.set('n', '<leader>gp', function() smart_git_push() end, { noremap = true, desc = "Git push" })
vim.keymap.set('n', '<leader>gs', function()
    execute_git_command('status', 'Git status retrieved', 'Git status failed')
end, { noremap = true, desc = "Git status" })
vim.keymap.set('n', '<leader>gd', function()
    execute_git_command('diff', 'Git diff retrieved', 'Git diff failed')
end, { noremap = true, desc = "Git diff" })
vim.keymap.set('n', '<leader>gl', function()
    execute_git_command('log --oneline --graph --all', 'Git log retrieved', 'Git log failed')
end, { noremap = true, desc = "Git log" })
vim.keymap.set('n', '<leader>gb', function()
    execute_git_command('branch', 'Git branches retrieved', 'Git branch failed')
end, { noremap = true, desc = "Git branch" })
vim.keymap.set('n', '<leader>gi', function()
    execute_git_command('init', 'Git repository initialized', 'Git init failed')
end, { noremap = true, desc = "Git init" })
vim.keymap.set('n', '<leader>gv', function()
    execute_git_command('remote -v', 'Git remotes retrieved', 'Git remote failed')
end, { noremap = true, desc = "Git remote -v" })
vim.keymap.set('n', '<leader>gr', function() add_git_remote() end, { noremap = true, desc = "Add git remote" })
vim.keymap.set('n', '<leader>gpl', function() smart_git_pull() end, { noremap = true, desc = "Git pull" })

-- Additional keybindings for new features
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = "Toggle file explorer" })
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true, desc = "Find files" })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true, desc = "Live grep" })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { noremap = true, silent = true, desc = "Find buffers" })
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { noremap = true, silent = true, desc = "Help tags" })

-- LSP diagnostic keybindings
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float,
    { noremap = true, silent = true, desc = "Open diagnostic float" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = "Go to previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = "Go to next diagnostic" })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist,
    { noremap = true, silent = true, desc = "Set diagnostic loclist" })

-- Create NewFile command
vim.api.nvim_create_user_command('NewFile', function(opts)
    local git_root = get_git_root()
    local filename = opts.args
    if filename == '' then
        filename = vim.fn.input('Enter filename: ')
    end
    if filename == '' then
        print("No filename provided")
        return
    end
    -- Construct the full path by joining git_root and filename
    local full_path = git_root .. '/' .. filename
    -- Get the directory path (parent directories of the file)
    local dir_path = vim.fn.fnamemodify(full_path, ':h')
    -- Create parent directories if they don't exist
    if vim.fn.isdirectory(dir_path) == 0 then
        vim.fn.mkdir(dir_path, 'p')
        print("Created directories: " .. dir_path)
    end
    -- Open the file for editing
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
    print("Creating new file: " .. full_path)
end, { nargs = '?' })

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = false,
    float = {
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
})

-- Set diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local function create_welcome_screen()
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true) -- false: not listed, true: scratch buffer
    vim.api.nvim_set_current_buf(buf)

    -- Define ASCII art
    local logo = {
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⡤⣤⢤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠛⠉⠀⠀⠀⠀⠀⠀⠉⠻⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠏⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠈⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠯⠀⠀⠀⢰⣿⣿⣿⣆⡀⣴⣾⣿⣦⡈⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣏⠀⠀⠀⠀⢸⣿⣿⣿⡿⠇⣿⣿⣿⣿⠆⠘⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠇⠀⠀⠀⠀⠈⠿⠿⡿⠃⠀⢿⣿⣿⠏⠀⠀⢹⣗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⢸⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⡐⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠘⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⡁⡿⠄⠀⢀⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠂⠀⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⣻⡷⠀⠠⣼⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣦⠀⠘⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⢠⡿⠃⠀⢡⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠸⣿⠆⠀⠸⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⢀⣿⠓⠀⠀⣼⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡧⠀⠀⠹⣯⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⢰⣾⡃⠀⠀⠀⣿⡄⠀⠀⠀⠀⠀⢰⣿⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⡀⠀⢮⠿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⣨⡿⠃⠀⠀⠀⢠⡿⠀⠀⠀⠀⠀⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠁⠚⣷⡀⠀⣀⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⣠⡾⠋⠀⠀⠀⠰⠀⢸⣇⠀⠀⠀⠀⠀⠀⠈⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⡿⠛⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠐⠿⠶⠶⠶⢤⣤⣤⣤⣼⣇⠀⠀⠀⠀⠀⡀⠀⡘⣷⠀⠀⠀⠀⠀⠀⠀⠈⢀⠀⠈⣿⣄⠀⠃⠀⠀⠀⠀⠀⠀⠀⢀]],
        [[⠀⠀⠀⢀⠀⠀⠁⢻⣏⠉⣿⡀⠀⠀⠀⠘⠅⠀⣈⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠈]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⢻⣶⡿⠃⠀⠀⢀⣬⣾⣿⡻⠋⣿⡆⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⡿⠯⠶⠾⠛⠁⠈⠘⣷⣿⠏⠀⢀⣴⠾⠋⠉⠉⠉⠙⠉⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⣮⠷⠟⠉⠀⠀⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
        "",
    }

    local name = {
        "Ashen Chathuranga | open-source is ♥",
        "", -- Empty line for spacing
    }

    local shortcuts = {
        "Essential Keybindings:",
        "",
        "<leader>e : Explorer    <leader>ff: Find Files    <leader>fg: Search",
        "<leader>ga: Git Add     <leader>gc: Git Commit    <leader>gp: Git Push",
        "<leader>w : Save        <leader>q : Quit          Press 'q' to close",
    }

    -- Define top margin (number of empty lines)
    local top_margin = 2
    local margin_lines = {}
    for i = 1, top_margin do
        table.insert(margin_lines, "")
    end

    -- Calculate the maximum line width for logo, name, and shortcuts separately
    local max_logo_width = 0
    for _, line in ipairs(logo) do
        max_logo_width = math.max(max_logo_width, vim.fn.strwidth(line))
    end

    local max_name_width = 0
    for _, line in ipairs(name) do
        max_name_width = math.max(max_name_width, vim.fn.strwidth(line))
    end

    local max_shortcuts_width = 0
    for _, line in ipairs(shortcuts) do
        max_shortcuts_width = math.max(max_shortcuts_width, vim.fn.strwidth(line))
    end

    -- Get the window width
    local win_width = vim.api.nvim_get_option("columns")

    -- Calculate padding to center each section
    local logo_padding = math.floor((win_width - max_logo_width) / 2)
    local name_padding = math.floor((win_width - max_name_width) / 2)
    local shortcuts_padding = math.floor((win_width - max_shortcuts_width) / 2)
    if logo_padding < 0 then logo_padding = 0 end
    if name_padding < 0 then name_padding = 0 end
    if shortcuts_padding < 0 then shortcuts_padding = 0 end

    -- Add padding to each section
    local padded_lines = {}
    for _, line in ipairs(margin_lines) do
        table.insert(padded_lines, line) -- No padding for empty margin lines
    end
    for _, line in ipairs(logo) do
        table.insert(padded_lines, string.rep(" ", logo_padding) .. line)
    end
    for _, line in ipairs(name) do
        table.insert(padded_lines, string.rep(" ", name_padding) .. line)
    end
    for _, line in ipairs(shortcuts) do
        table.insert(padded_lines, string.rep(" ", shortcuts_padding) .. line)
    end

    -- Set the lines in the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded_lines)

    -- Buffer options
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')   -- Delete buffer when hidden
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')   -- Not a file
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)   -- Read-only
    vim.api.nvim_buf_set_option(buf, 'filetype', 'welcome') -- Custom filetype

    -- Highlighting
    for i = 1, top_margin do
        vim.api.nvim_buf_add_highlight(buf, -1, 'Normal', i - 1, 0, -1) -- Empty lines
    end
    for i = 1, #logo do
        vim.api.nvim_buf_add_highlight(buf, -1, 'Normal', top_margin + i - 1, 0, -1) -- Logo
    end
    for i = 1, #name do
        vim.api.nvim_buf_add_highlight(buf, -1, 'Title', top_margin + #logo + i - 1, 0, -1) -- Name
    end
    for i = 1, #shortcuts do
        vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', top_margin + #logo + #name + i - 1, 0, -1) -- Shortcuts
    end

    -- Keymappings for the welcome buffer
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', 'q', ':q<CR>', opts) -- Quit the welcome screen
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
    vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', opts)
    vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
    vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', opts)
    vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

    -- Window options
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = 'no'
    vim.wo.cursorline = false
end

-- Autocommand to trigger the welcome screen
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 and vim.fn.line2byte(1) == -1 then -- No file opened
            create_welcome_screen()
        end
    end,
})

-- Enable line numbers only for normal file buffers
vim.api.nvim_create_autocmd({"BufWinEnter", "BufRead", "BufNewFile"}, {
    callback = function()
        -- Only enable for regular files (not welcome screen)
        if vim.bo.filetype ~= "welcome" then
            vim.wo.number = true
            vim.wo.relativenumber = true
        end
    end,
})
