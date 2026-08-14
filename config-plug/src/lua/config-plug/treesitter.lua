vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local ok = pcall(vim.treesitter.get_parser, args.buf)
    if ok then
			vim.treesitter.start()
		else
			print("No treesitter grammar found")
		end
  end,
})
