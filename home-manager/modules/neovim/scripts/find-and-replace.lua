-- Search and replace text in the current buffer based on user input

local M = {}

function M.input()
    vim.ui.input({
        prompt = "Value to find > "
    }, function(find)
        vim.cmd(":redraw") -- Clear prompt
        if find then
            local line = vim.fn.search(find, 'c')
            if line ~= 0 then
                vim.ui.input({
                    prompt = "Value to replace > "
                }, function(replace)
                    if replace then
                        vim.cmd(":%s/" .. find .. "/" .. replace .. "/g")
                        vim.cmd(":redraw")
                        print("Replaced '" .. find .. "' with '" .. replace .. "'")
                    end
                end)
            else
                print("Could not find '" .. find .. "'")
            end
        end
    end)
end

M.input()
return M
