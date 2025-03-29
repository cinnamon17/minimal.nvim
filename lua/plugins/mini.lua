return {
    {
	'echasnovski/mini.nvim',
	version = false,  -- Set to specific version if needed, e.g., '*'
	config = function()  -- Note: 'config' not 'configs'
	    require('mini.statusline').setup()
	    require('mini.icons').setup()  -- Example of another mini module
	end
    }
}
