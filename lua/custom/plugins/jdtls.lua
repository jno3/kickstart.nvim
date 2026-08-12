vim.pack.add { 'https://github.com/mfussenegger/nvim-jdtls' }

local function load_env(path)
  local vars = {}
  local file = io.open(path, 'r')
  if not file then return vars end

  for line in file:lines() do
    local k, v = line:match('^%s*([%w_]+)%s*=%s*(.-)%s*$')
    if k and v then vars[k] = v end
  end

  file:close()
  return vars
end

local env_path = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h:h:h') .. '/.env'
local env = load_env(env_path)

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local jdtls = require('jdtls')

    local root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
    if not root_dir then return end

    local project_name = vim.fn.fnamemodify(root_dir, ':t')
    local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name
    vim.fn.mkdir(workspace_dir, 'p')

    local java_home = env.JAVA_HOME or os.getenv('JAVA_HOME')
    local jdtls_jar = env.JDTLS_JAR or os.getenv('JDTLS_JAR')
    local jdtls_config = env.JDTLS_CONFIG or os.getenv('JDTLS_CONFIG')
    local debug_plugin = env.DEBUG_PLUGIN or os.getenv('DEBUG_PLUGIN')
    local tests_jars = env.TESTS_JARS or os.getenv('TESTS_JARS')


    local bundles = vim.fn.glob(debug_plugin, true, true)
    local java_test_bundles = vim.split(vim.fn.glob(tests_jars, 1), "\n")
    local excluded = {
      "com.microsoft.java.test.runner-jar-with-dependencies.jar",
      "jacocoagent.jar",
    }
    for _, java_test_jar in ipairs(java_test_bundles) do
      local fname = vim.fn.fnamemodify(java_test_jar, ":t")
      if not vim.tbl_contains(excluded, fname) then
        table.insert(bundles, java_test_jar)
      end
    end

    local config = {
      cmd = {
        java_home .. "/bin/java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "-Xmx1G",
        "--add-modules=ALL-SYSTEM",
        "--add-opens=java.base/java.util=ALL-UNNAMED",
        "--add-opens=java.base/java.lang=ALL-UNNAMED",
        "-jar", jdtls_jar,
        "-configuration", jdtls_config,
        "-data", workspace_dir 
      },
      init_options = {
        bundles = bundles,
      },
      on_attach = function(client, bufnr)
        jdtls.setup_dap({ hotcodereplace = 'auto' })
        
        require('jdtls.dap').setup_dap_main_class_configs()

        vim.keymap.set('n', '<leader>df', function()
          require('jdtls').pick_to_debug()
        end, { buffer = bufnr, desc = "Java: Pick Main Class & Debug" })
      end,
      root_dir = root_dir,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      settings = {
        java = {
          signatureHelp = { enabled = true },
          completion = { enabled = true },
        },
      },
    }

    jdtls.start_or_attach(config)
  end,
})
