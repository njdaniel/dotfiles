return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		-- Enable debugging for nvim-lint
		vim.g.lint_debug = true

		local lint = require("lint")

		-- lint.linters.cfn_lint = {
		-- 	name = "cfn-lint",
		-- 	cmd = "cfn-lint", -- Ensure cfn-lint is in your PATH
		-- 	stdin = false, -- cfn-lint doesn't use stdin
		-- 	args = { "$FILENAME" }, -- Pass the file name as an argument
		-- 	stream = "stderr", -- Read from standard error
		-- 	ignore_exitcode = true, -- Don't fail on non-zero exit codes
		-- 	parser = require("lint.parser").from_errorformat([[%f:%l:%c: %m]], { source = "cfn-lint" }),
		-- }

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			golang = { "golangcilint" },
			-- yaml = { "cfn_lint" },
		}

		-- Add conditional linting for CloudFormation YAML files
		-- local function set_cfn_lint()
		-- 	local filename = vim.fn.expand("%:t") -- Get current file's name
		-- 	if filename == "cloudformation.yaml" or filename == "template.yaml" then
		-- 		lint.linters_by_ft.yaml = { "cfn-lint" }
		-- 	else
		-- 		lint.linters_by_ft.yaml = nil -- Disable cfn-lint for other YAML files
		-- 	end
		-- end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- set_cfn_lint() --Dynamically configure the linter
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>l", function()
			-- set_cfn_lint() -- Ensure the linter is set before triggering
			lint.try_lint()
		end, { desc = "Trigger linting for current file" })
	end,
}
