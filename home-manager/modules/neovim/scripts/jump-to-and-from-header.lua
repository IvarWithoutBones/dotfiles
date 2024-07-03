-- Helpers to jump between c/c++ files and headers with the same base name, intended to be used with a keybinding.
-- For example: executing `jump_to_and_from_header()` while editing `foo.cpp`/`foo.c` will jump to `foo.h`, and vice versa.

require("vim.fs")

---@param target table The file(s) to look for
---@param path string The directory to look in, before searching through the git root
---@return string?
local function find_file(target, path)
    -- First look in the same directory as our currently opened file
    local result_children = vim.fs.find(target, { type = "file", path = path })
    if #result_children ~= 0 then
        return result_children[1]
    else
        -- If we cannot find it there, recursively look through each subdirectory from the git root.
        local git_root = vim.fs.root(0, '.git')
        if git_root == nil then return nil end
        local result_git_root = vim.fs.find(target, { type = "file", path = git_root })
        if #result_git_root == 0 then return nil end
        return result_git_root[1]
    end
end

local function jump_to_and_from_header()
    -- Get the path to the currently opened file, if any
    local path = vim.api.nvim_buf_get_name(0)
    if path == nil then return end
    path = vim.fs.normalize(path)

    -- Split the path into the base name and the extension: `src/foo.cpp` -> `foo` and `cpp`
    local basename = vim.fs.basename(path)
    local extension = basename:match("[^.]+$")                 -- Note: we cannot use `vim.bo.filetype` here since it treats headers the same as c/cpp
    local target = basename:sub(1, #basename - #extension - 1) -- Basename without the file extension

    -- Choose the target filename(s) based on the extension of the currently opened file
    if extension == "cpp" then
        target = { target .. ".h", target .. ".hpp" }
    elseif extension == "hpp" then
        target = { target .. ".cpp" }
    elseif extension == "c" then
        target = { target .. ".h" }
    elseif extension == "h" then
        target = { target .. ".cpp", target .. ".c" }
    else
        print("not a header or c/cpp file")
        return
    end

    -- Try to find our target file
    local result = find_file(target, vim.fs.dirname(path))
    if result == nil then
        print("could not find associated file " .. table.concat(target, "/"))
        return
    end

    -- Finally, print and open the target
    print(result)
    vim.cmd("edit " .. result)
end

jump_to_and_from_header()
