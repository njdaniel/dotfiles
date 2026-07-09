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
				local function map(keys, func, desc)
					keymap.set("n", keys, func, { buffer = ev.buf, silent = true, desc = desc })
				end

				-- LSP navigation and actions
				map("gR", "<cmd>Telescope lsp_references<CR>", "Show LSP references")
				map("gd", vim.lsp.buf.definition, "Go to definition")
				map("gD", vim.lsp.buf.declaration, "Go to declaration")
				map("gi", vim.lsp.buf.implementation, "Go to implementation")
				map("gt", vim.lsp.buf.type_definition, "Go to type definition")
				map("K", vim.lsp.buf.hover, "Show hover documentation")
				map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action")

				-- Diagnostics workflow
				map("<leader>d", vim.diagnostic.open_float, "Show line diagnostics")
				map("[d", vim.diagnostic.goto_prev, "Go to previous diagnostic")
				map("]d", vim.diagnostic.goto_next, "Go to next diagnostic")
				map("<leader>q", vim.diagnostic.setloclist, "Add diagnostics to location list")
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
				-- Auto-organize imports before saving the file.
				-- The augroup is shared across Go buffers, so it must not be
				-- cleared globally here; only this buffer's autocmds are reset
				-- to avoid duplicates when gopls re-attaches.
				local group = vim.api.nvim_create_augroup("GoOrganizeImports", { clear = false })
				vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = group,
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
