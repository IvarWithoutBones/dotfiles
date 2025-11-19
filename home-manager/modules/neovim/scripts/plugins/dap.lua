local function binding(key, action, desc, mode)
    vim.keymap.set(mode or "n", key, action, { noremap = true, desc = desc })
end

local function exepath_or_binary(binary)
    local exe_path = vim.fn.exepath(binary)
    return #exe_path > 0 and exe_path or binary
end

local function pickProgram()
    local path = vim.fn.input({
        prompt = 'Path to executable: ',
        default = vim.fn.getcwd() .. '/',
        completion = 'file'
    })
    return (path and path ~= "") and path or require("dap").ABORT
end

-- Show the values of variables next to their declaration.
require("nvim-dap-virtual-text").setup({
    only_first_definition = false,
    virt_text_pos = "eol",
})

-- A UI for the debugging context.
local ui = require("dapui")

---@diagnostic disable-next-line: missing-fields
ui.setup({
    floating = { border = "rounded" }, ---@diagnostic disable-line: missing-fields
    layouts = {
        {
            position = "left",
            size = 40,
            elements = {
                { id = "scopes",  size = 0.60 },
                { id = "watches", size = 0.15 },
                { id = "stacks",  size = 0.25 },
            },
        },
        {
            position = "bottom",
            size = 10,
            elements = {
                { id = "console", size = 0.25 },
                { id = "repl",    size = 0.75 },
            },
        }
    },
})

-- Automatically open/close the UI
local dap = require("dap")
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

-- Set up of handlers for probe-rs RTT messages. Adapted from https://probe.rs/docs/tools/debugger/.
-- If RTT is enabled, probe-rs sends an event after initializing a channel. This has to be confirmed, otherwise probe-rs won't sent RTT data.
dap.listeners.before["event_probe-rs-rtt-channel-config"]["plugins.nvim-dap-probe-rs"] = function(session, body)
    local msg = string.format('probe-rs: opening RTT channel #%d: "%s"', body.channelNumber, body.channelName)
    require("dap.utils").notify(msg, vim.log.levels.INFO)
    session:request("rttWindowOpened", { body.channelNumber, true })
end

-- Handle probe-rs RTT data messages by displaying them in the REPL.
dap.listeners.before["event_probe-rs-rtt-data"]["plugins.nvim-dap-probe-rs"] = function(_, body)
    local msg = string.format("probe-rs RTT channel #%d: %s", body.channelNumber, body.data)
    require("dap.repl").append(msg)
end

-- Display probe-rs messages in the REPL.
dap.listeners.before["event_probe-rs-show-message"]["plugins.nvim-dap-probe-rs"] = function(_, body)
    require("dap.repl").append(string.format("probe-rs: %s", body.message))
end

-- Add Python support, requires the `nvim-dap-python` plugin and the `debugpy` package.
require("dap-python").setup(exepath_or_binary("debugpy-adapter"))

-- Debug adapters
dap.adapters["gdb"] = {
    name = "gdb",
    type = "executable",
    command = exepath_or_binary("gdb"),
    args = { "--interpreter=dap" }
}

dap.adapters["lldb"] = {
    name = "lldb",
    type = "executable",
    command = exepath_or_binary("lldb-dap"),
}

dap.adapters["codelldb"] = {
    name = "codelldb",
    type = "server",
    port = "${port}",
    executable = {
        command = exepath_or_binary('codelldb'),
        args = { '--port', '${port}' },
    },
}

dap.adapters["probe-rs-debug"] = {
    name = "probe-rs-debug",
    type = "server",
    port = "${port}",
    executable = {
        command = exepath_or_binary("probe-rs"),
        args = { "dap-server", "--port", "${port}" },
    },
}

-- Associate specific `type` values in `.vscode/launch.json` files with configured filetypes.
local vscode_dap = require("dap.ext.vscode")
vscode_dap.type_to_filetypes["cppdbg"] = { "c", "cpp" }
vscode_dap.type_to_filetypes["codelldb"] = { "c", "cpp", "rust" }
vscode_dap.type_to_filetypes["lldb"] = { "c", "cpp", "rust" }
vscode_dap.type_to_filetypes["gdb"] = { "c", "cpp", "rust" }
vscode_dap.type_to_filetypes["probe-rs-debug"] = { "rust" }

-- Language configurations. Note that Rust is configured by rustaceanvim (using codelldb).
dap.configurations.c = {
    {
        name = "Launch (GDB)",
        type = "gdb",
        request = "launch",
        program = pickProgram,
        cwd = "${workspaceFolder}",
    },
    {
        name = 'Launch (LLDB)',
        type = 'lldb',
        request = 'launch',
        program = pickProgram,
        cwd = '${workspaceFolder}',
    },
    {
        name = "Launch (CodeLLDB)",
        type = "codelldb",
        request = "launch",
        program = pickProgram,
        cwd = "${workspaceFolder}",
    }
}

dap.configurations.cpp = vim.deepcopy(dap.configurations.c)

-- keybindings
binding("<space>du", function() ui.toggle() end, "Toggle DAP UI")
binding("<space>dR", function() dap.repl.open() end, "Toggle DAP REPL")
binding("<space>db", function() dap.toggle_breakpoint() end, "Toggle breakpoint at cursor")
binding("<space>dc", function() dap.continue() end, "Start/continue debugging session")
binding("<space>di", function() dap.step_into() end, "Step into")
binding("<space>do", function() dap.step_over() end, "Step over")
binding("<space>dp", function() dap.step_out() end, "Step out")
binding("<space>dl", function() dap.run_last() end, "Run previous debug adapter")
binding("<space>dr", function() dap.restart() end, "Restart debugging session")
binding("<space>dB", function() require("telescope").extensions.dap.list_breakpoints() end, "List breakpoints")
binding("<space>dh", function() require("dap.ui.widgets").hover() end, "Evaluate expression", { "n", "v" })
