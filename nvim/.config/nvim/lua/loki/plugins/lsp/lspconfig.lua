-- lspconfig.lua

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Import required plugins
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap -- for conciseness

		-- Create an autocommand group for LSP
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				-- Keymaps for LSP
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				-- Add other keymaps here...
			end,
		})

		-- Set up capabilities for nvim-cmp
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Customize Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Set up mason-lspconfig with handlers
		mason_lspconfig.setup_handlers({
			-- Default handler for installed servers
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,
			-- Specific handler for yamlls
			["yamlls"] = function()
				lspconfig.yamlls.setup({
					capabilities = capabilities,
					settings = {
						yaml = {
							schemas = {
								["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*",
								["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose.yml",
								-- Kubernetes schemas
								["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.25.0-standalone-strict/all.json"] = {
									"*.k8s.yaml",
									"*.k8s.yml",
								},
								-- AWS SAM schema
								["https://raw.githubusercontent.com/aws/serverless-application-model/main/samtranslator/schema/schema.json"] = {
									"template.yaml",
									"template.yml",
								},
								-- Cloudformation schema
								["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = {
									"cloudformation.yaml",
									"cloudformation.yml",
								},
								-- Add more schema associations as needed
							},
							keyOrdering = false,
							validate = true,
							customTags = {
								"!Ref scalar",
								"!Sub scalar",
								"!GetAtt scalar",
								"!Join sequence",
								"!If sequence",
								"!FindInMap sequence",
								"!Base64 scalar",
								"!ImportValue scalar",
								"!Select sequence",
								"!Split sequence",
								"!Equals sequence",
								"!And sequence",
								"!Or sequence",
								"!Not sequence",
							},
						},
					},
					on_attach = function(client, bufnr)
						-- You can add buffer-local keybindings or settings here
						-- For example:
						-- require("your_custom_module").setup(bufnr)
					end,
				})
			end,
			-- Add other specific server handlers here...
			["svelte"] = function()
				-- Existing svelte server configuration
				lspconfig["svelte"].setup({
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
					end,
				})
			end,
			["graphql"] = function()
				lspconfig["graphql"].setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				})
			end,
			["emmet_ls"] = function()
				lspconfig["emmet_ls"].setup({
					capabilities = capabilities,
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
				})
			end,
			["lua_ls"] = function()
				lspconfig["lua_ls"].setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							completion = { callSnippet = "Replace" },
						},
					},
				})
			end,
			["gopls"] = function()
				-- Existing gopls server configuration
				lspconfig["gopls"].setup({
					capabilities = capabilities,
					cmd = { "gopls" },
					filetypes = { "go", "gomod" },
					root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
					settings = {
						gopls = {
							gofumpt = true, -- Enable stricter formatting
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
							["ui.completion.usePlaceholders"] = true,
						},
					},
					on_attach = function(client, bufnr)
						-- Auto-organize imports before saving the file
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = vim.api.nvim_create_augroup("GoOrganizeImports", { clear = true }),
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.code_action({
									context = { only = { "source.organizeImports" }, diagnostics = {} },
									apply = true,
								})
							end,
						})
					end,
				})
			end,
		})
	end,
}
