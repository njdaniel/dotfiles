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

		-- Customize Diagnostic symbols in the sign column (gutter)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Apply cmp-nvim-lsp capabilities to every server by default.
		-- Per-server overrides below are merged on top of this base config.
		vim.lsp.config("*", {
			capabilities = cmp_nvim_lsp.default_capabilities(),
		})

		vim.lsp.config("yamlls", {
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
		})

		vim.lsp.config("svelte", {
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePost", {
					pattern = { "*.js", "*.ts" },
					callback = function(ctx)
						client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
					end,
				})
			end,
		})

		vim.lsp.config("graphql", {
			filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		})

		vim.lsp.config("emmet_ls", {
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

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					completion = { callSnippet = "Replace" },
				},
			},
		})

		vim.lsp.config("gopls", {
			cmd = { "gopls" },
			filetypes = { "go", "gomod" },
			root_markers = { "go.work", "go.mod", ".git" },
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

		-- mason-lspconfig's `automatic_enable` (see mason.lua) calls
		-- vim.lsp.enable() for every Mason-installed server using the configs
		-- registered above, so no manual vim.lsp.enable() call is needed here.
	end,
}
