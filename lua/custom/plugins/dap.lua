vim.pack.add { 'https://codeberg.org/mfussenegger/nvim-dap' }
vim.pack.add { 'https://github.com/rcarriga/nvim-dap-ui' }
vim.pack.add { 'https://github.com/nvim-neotest/nvim-nio' }

vim.schedule(
    function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()

        dap.listeners.before.attach.dapui_config = function() dapui.open() end
        dap.listeners.before.launch.dapui_config = function() dapui.open() end
        dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
        dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end
)
