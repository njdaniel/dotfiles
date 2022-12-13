-- import nvim_dap plugin safely
local dap_status, dap = pcall(require, "nvim-dap")
if not dap_status then
	return
end

dap.setup()

--keymaps

-- from the :help dap-mappings
-- nothing setup by default
-- >vim
--     nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
--     nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
--     nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
--     nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
--     nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
--     nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
--     nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
--     nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
--     nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
-- <
-- local keymap = vim.keymap
-- local on_attach = function(bufnr)
-- 	-- keybind options
-- 	local opts = { noremap = true, silent = true, buffer = bufnr }
-- 	keymap.set("n", "<leader>b", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
-- end

-- Dap go
local dapgo_status, dapgo = pcall(require, "dap-go")
if not dapgo_status then
	return
end

dapgo.setup()
