return {
    {"hrsh7th/nvim-cmp",
    dependencies = {
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"mfussenegger/nvim-dap"
    },
    opts = function()
	local cmp = require('cmp')
	cmp.setup({
	    completion = {
		completeopt = 'menu,menuone,noinsert,noselect'
	    },
	    mapping = {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-y>'] = cmp.mapping.confirm { select = true },
		['<C-Space>'] = cmp.mapping.complete {},
	    },
	    sources = {
		{ name = 'nvim_lsp' },  -- Includes PHP Actor completions
		{ name = 'buffer' },
		{ name = 'path' }
	    }
	})
    end
}
}
