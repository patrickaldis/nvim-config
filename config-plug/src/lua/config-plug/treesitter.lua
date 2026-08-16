vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    if vim.bo[args.buf].buftype == "" then
        local ok = pcall(vim.treesitter.start, args.buf)
        if not ok then
            print("No treesitter parser found")
            return
        end
    end
  end,
})
