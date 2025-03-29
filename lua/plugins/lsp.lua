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
	config = function()
	    vim.keymap.set('n', '<A-o>', function()
		require('jdtls').organize_imports()
	    end, { desc = 'Organize Java imports' })

	    -- Extract variable (normal and visual mode)
	    vim.keymap.set('n', 'crv', function()
		require('jdtls').extract_variable()
	    end, { desc = 'Extract variable' })

	    vim.keymap.set('v', 'crv', function()
		require('jdtls').extract_variable(true)
	    end, { desc = 'Extract variable (visual)' })

	    -- Extract constant (normal and visual mode)
	    vim.keymap.set('n', 'crc', function()
		require('jdtls').extract_constant()
	    end, { desc = 'Extract constant' })

	    vim.keymap.set('v', 'crc', function()
		require('jdtls').extract_constant(true)
	    end, { desc = 'Extract constant (visual)' })

	    -- Extract method (visual mode only)
	    vim.keymap.set('v', 'crm', function()
		require('jdtls').extract_method(true)
	    end, { desc = 'Extract method' })
	    require("lspconfig").jdtls.setup {
		cmd = {'/usr/local/src/jdt-language-server-latest/bin/jdtls'},
		root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1])
	    }
	end,

    },
    -- PHP
    {
	-- PHP Actor configuration with Symfony support
	'phpactor/phpactor',
	config = function()
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
		    -- Enable Symfony support
		    ["symfony.enabled"] = true,
		    -- Default Symfony container path (adjust if needed)
		    ["symfony.xml_path"] = "var/cache/dev/App_KernelDevDebugContainer.xml",

		    -- Other PHP Actor options
		    ["language_server_phpstan.enabled"] = false,
		    ["language_server_psalm.enabled"] = false,
		},
		settings = {
		    phpactor = {
			symfony = {
			    enabled = true,
			    -- Optional: specify alternative container path if different
			    -- container_path = "var/cache/dev/App_KernelDevDebugContainer.xml"
			},
			completion = {
			    enabled = true,
			    insertUseDeclaration = true,
			}
		    }
		}
	    }
	end
    }
}
