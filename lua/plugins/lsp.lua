return {
    -- Java
    {
	"mfussenegger/nvim-jdtls",
	ft = "java",
	dependencies = {
	    "hrsh7th/nvim-cmp",
	    "hrsh7th/cmp-nvim-lsp",
	    "hrsh7th/cmp-path",
	    "hrsh7th/cmp-buffer",
	    "mfussenegger/nvim-dap"
	},
	config = function()

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

	    -- Enhanced JDTLS configuration
	    local root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw', 'build.gradle', 'pom.xml', 'settings.gradle'}, { upward = true })[1])
	    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
	    local workspace_dir = vim.fn.stdpath('data') .. '/workspace/' .. project_name
	    local is_libgdx = vim.fn.findfile('core/build.gradle', root_dir..';') ~= ''
	    -- wen auto installed edit the jdtls.py and replace JAVA_HOME to match JAVA_JDK_21 and set the environment variable
	    local jdtls_bin = vim.env.MASON .. '/bin/jdtls'
	    if jit.os == "Windows" then
		-- match JAVA_JDK_21
		-- get from https://download.eclipse.org/jdtls/snapshots/?d
		jdtls_bin = vim.fn.expand('~/AppData/Local/jdt-language-server-latest/bin/jdtls');
	    end
	    local config = {
		cmd = {jdtls_bin},
		root_dir = root_dir,
		settings = {
		    java = {
			configuration = {
			    updateBuildConfiguration = "automatic",
			    annotationProcessing = {
				enabled = true,
				fileOutput = {
				    enabled = true,
				    directory = "${project_dir}/build/generated/sources/annotationProcessor/java/main"
				}
			    }
			},
			completion = {
			    favoriteStaticMembers = {
				"org.springframework.*",
				"org.junit.*",
				"org.mockito.Mockito.*",
				-- LibGDX additions (only added if libGDX detected)
				is_libgdx and "com.badlogic.gdx.*" or nil,
			    },
			    importOrder = is_libgdx and { "com.badlogic", "java", "javax", "" } or nil
			}
		    }
		},
		init_options = {
		    extendedClientCapabilities = {
			progressReportProvider = true,
			classFileContentsSupport = true,
			-- LibGDX-specific enhancements
			advancedOrganizeImportsSupport = is_libgdx or nil
		    },
		    bundles = {
			vim.fn.glob("/usr/local/src/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.53.2.jar", true)
		    },
		    workspace = workspace_dir,
		    jvm_args = is_libgdx and {
			"-Xms1g",
			"-Xmx4g",
			"--add-opens", "java.base/java.util=ALL-UNNAMED"
		    } or nil
		},
		capabilities = require('cmp_nvim_lsp').default_capabilities()
	    }

	    -- Start JDTLS with the enhanced config
	    require("lspconfig").jdtls.setup(config)

	    -- Your existing nvim-cmp setup (unchanged)
	    vim.api.nvim_create_autocmd('FileType', {
		pattern = 'java',
		callback = function()
		    local cmp = require('cmp')
		    cmp.setup.buffer({
			completion = {
			    completeopt = 'menu,menuone,noinsert,noselect'
			},
			sources = cmp.config.sources({
			    { name = 'nvim_lsp' },
			    { name = 'buffer' },
			    { name = 'path' }
			})
		    })
		end
	    })

	    -- Proper shutdown on exit
	    vim.api.nvim_create_autocmd('VimLeave', {
		callback = function()
		    if vim.fn.has('unix') == 1 then
			os.execute("killall -9 java 2>/dev/null")
		    end
		end,
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
	    'neovim/nvim-lspconfig',
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
	    -- Optional: PHP-specific keymaps
	    vim.api.nvim_create_autocmd('FileType', {
		pattern = 'php',
		callback = function()
		    vim.keymap.set('n', '<leader>pc', '<cmd>PhpactorContextMenu<CR>', { buffer = true, desc = 'PHP Context Menu' })
		    vim.keymap.set('n', '<leader>pi', '<cmd>PhpactorImportClass<CR>', { buffer = true, desc = 'Import Class' })
		end
	    })
	end
    },
}
