local function binding(key, action, desc, mode)
    vim.keymap.set(mode or "n", key, action, { noremap = true, desc = desc })
end

local function pickProgram()
    -- TODO: Switch to something like telescope
    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
end

-- Show the values of variables next to their declaration.
require("nvim-dap-virtual-text").setup({
    only_first_definition = false,
})

-- A UI for the debugging context.
local ui = require("dapui")
ui.setup({
    layouts = {
        {
            position = "left",
            size = 40,
            elements = {
                { id = "scopes",  size = 0.60 },
                { id = "watches", size = 0.25 },
                { id = "stacks",  size = 0.15 },
            },
        },
        {
            position = "bottom",
            size = 10,
            elements = {
                { id = "repl",    size = 0.75 },
                { id = "console", size = 0.25 },
            },
        }
    },
})

local dap = require("dap")

-- Automatically open/close the UI
dap.listeners.before.attach.dapui_config = function() ui.open() end
dap.listeners.before.launch.dapui_config = function() ui.open() end
dap.listeners.before.event_terminated.dapui_config = function() ui.close() end
dap.listeners.before.event_exited.dapui_config = function() ui.close() end

-- Manually refresh/clear things like the local variables upon certain events
for _, event in ipairs({ "event_terminated", "continue", "restart", "disconnect" }) do
    dap.listeners.after[event]['refresh_dap_ui'] = function(_, _)
        require("dapui.controls").refresh_control_panel()
    end
end

-- Signcolumn icons
vim.fn.sign_define('DapStopped', { text = '🟢', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = '', linehl = '', numhl = '' })

-- Debug adapters
dap.adapters.gdb = {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap" }
}

local gdb = {
    name = "Launch (GDB)",
    type = "gdb",
    request = "launch",
    program = pickProgram,
    cwd = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = false,
}

dap.adapters.lldb = {
    type = "executable",
    command = "lldb-dap",
    name = "lldb"
}

local lldb = {
    name = 'Launch (LLDB)',
    type = 'lldb',
    request = 'launch',
    program = pickProgram,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
}

dap.configurations.c = { gdb, lldb }
dap.configurations.cpp = { gdb, lldb }
dap.configurations.rust = { gdb, lldb }

-- keybindings
binding("<space>du", function() ui.toggle() end, "Toggle DAP UI")
binding("<space>dR", function() dap.repl.open() end, "Toggle DAP REPL")
binding("<space>db", function() dap.toggle_breakpoint() end, "Toggle breakpoint at cursor")
binding("<space>dc", function() dap.continue() end, "Continue debugging session")
binding("<space>di", function() dap.step_into() end, "Step into")
binding("<space>do", function() dap.step_over() end, "Step over")
binding("<space>dp", function() dap.step_out() end, "Step out")
binding("<space>dl", function() dap.run_last() end, "Run previous debug adapter")
binding("<space>dr", function() dap.restart() end, "Restart debugging session")
binding("<space>dB", function() require("telescope").extensions.dap.list_breakpoints() end, "List breakpoints")
binding("<space>dh", function() require("dap.ui.widgets").hover() end, "Evaluate expression", { "n", "v" })
