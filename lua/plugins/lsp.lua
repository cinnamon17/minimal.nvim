return {
    -- Lua
    {
	"neovim/nvim-lspconfig",
	dependencies = {
	    {
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
		    library = {
			-- See the configuration section for more details
			-- Load luvit types when the `vim.uv` word is found
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		    },
		},
	    }
	},
	config = function()
	    require("lspconfig").lua_ls.setup {}
	end,
    },

    -- Java
    {
	"mfussenegger/nvim-jdtls",
	ft = "java",  -- Only load for Java files
	dependencies = {  -- Add completion dependencies
	    "hrsh7th/nvim-cmp",
	    "hrsh7th/cmp-nvim-lsp",
	    "hrsh7th/cmp-path",
	    "hrsh7th/cmp-buffer"
	},
	config = function()
	    -- Your existing keymaps (unchanged)
	    vim.keymap.set('n', '<A-o>', function()
		require('jdtls').organize_imports()
	    end, { desc = 'Organize Java imports' })

	    vim.keymap.set('n', 'crv', function()
		require('jdtls').extract_variable()
	    end, { desc = 'Extract variable' })

	    vim.keymap.set('v', 'crv', function()
		require('jdtls').extract_variable({visual = true})
	    end, { desc = 'Extract variable (visual)' })

	    vim.keymap.set('n', 'crc', function()
		require('jdtls').extract_constant()
	    end, { desc = 'Extract constant' })

	    vim.keymap.set('v', 'crc', function()
		require('jdtls').extract_constant({visual = true})
	    end, { desc = 'Extract constant (visual)' })

	    vim.keymap.set('v', 'crm', function()
		require('jdtls').extract_method({visual = true})
	    end, { desc = 'Extract method' })

	    -- JDTLS Setup with completion capabilities
	    require("lspconfig").jdtls.setup {
		cmd = {'/usr/local/src/jdt-language-server-latest/bin/jdtls'},
		root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
		capabilities = require('cmp_nvim_lsp').default_capabilities(),
	    }

	    -- Set up nvim-cmp for Java files
	    vim.api.nvim_create_autocmd('FileType', {
		pattern = 'java',
		callback = function()
		    local cmp = require('cmp')
		    cmp.setup.buffer({
			completion = {
			    completeopt = 'menu,menuone,noinsert,noselect'
			},
			sources = cmp.config.sources({
			    { name = 'nvim_lsp' },  -- JDTLS completions
			    { name = 'buffer' },    -- Buffer words
			    { name = 'path' },      -- File paths
			})
		    })
		end
	    })
	end
    },

    -- PHP
    {
	'phpactor/phpactor',
	ft = 'php',
	build = 'composer install',  -- Added build step
	dependencies = {  -- Added completion dependencies
	    'hrsh7th/nvim-cmp',
	    'hrsh7th/cmp-nvim-lsp',
	    'neovim/nvim-lspconfig'
	},
	config = function()
	    -- Your existing PHP Actor configuration
	    require("lspconfig").phpactor.setup {
		cmd = { "phpactor", "language-server" },
		filetypes = { "php" },
		root_dir = function(fname)
		    local root_files = {
			'composer.json',
			'.git',
			'.phpactor.json',
			'phpactor.yml',
			'symfony.lock'
		    }
		    return require('lspconfig.util').root_pattern(unpack(root_files))(fname) or
		    vim.fn.expand('%:p:h')
		end,
		init_options = {
		    ["symfony.enabled"] = true,
		    ["symfony.xml_path"] = "var/cache/dev/App_KernelDevDebugContainer.xml",
		    ["language_server_phpstan.enabled"] = false,
		    ["language_server_psalm.enabled"] = false,
		},
		settings = {
		    phpactor = {
			symfony = {
			    enabled = true,
			},
			completion = {
			    enabled = true,
			    insertUseDeclaration = true,
			}
		    }
		}
	    }

	    -- Add nvim-cmp configuration (preserves your PHP Actor setup)
	    local cmp = require('cmp')
	    cmp.setup({
		completion = {
		    completeopt = 'menu,menuone,noinsert,noselect'
		},
		sources = {
		    { name = 'nvim_lsp' },  -- Includes PHP Actor completions
		    { name = 'buffer' },
		    { name = 'path' }
		}
	    })

	    -- Optional: PHP-specific keymaps
	    vim.api.nvim_create_autocmd('FileType', {
		pattern = 'php',
		callback = function()
		    vim.keymap.set('n', '<leader>pc', '<cmd>PhpactorContextMenu<CR>', { buffer = true, desc = 'PHP Context Menu' })
		    vim.keymap.set('n', '<leader>pi', '<cmd>PhpactorImportClass<CR>', { buffer = true, desc = 'Import Class' })
		end
	    })
	end
    }
}
