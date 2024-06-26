local config = require("remember_me.config")
Session = {}
Session.__index = Session

local function FNV_hash(s)
    local prime = 1099511628211
    local hash = 14695981039346656037
    for i = 1, #s do
        hash = require("bit").bxor(hash, s:byte(i))
        hash = hash * prime
    end
    return hash
end

function Session.new(project_name, project_path)
    local ses = setmetatable({}, Session)
    ses.name = string.format("%s__%u", project_name, FNV_hash(project_path))
    ses.ext = config.ext
    ses.store = config.session_store
    return ses
end

local function safely_close_trees()
    local nvim_tree_present, api = pcall(require, "nvim-tree.api")
    if nvim_tree_present then
        api.tree.close()
    end
    if pcall(require, "neo-tree") then
        vim.cmd([[Neotree action=close]])
    end
end

function Session:save()
    os.execute("mkdir -p " .. self.store)
    safely_close_trees()
    local session = self.store .. self.name .. self.ext
    local mksession_cmd = vim.api.nvim_parse_cmd("mksession! " .. session, {})
    vim.api.nvim_cmd(mksession_cmd, {})
end

function Session:load()
    local session = self.store .. self.name .. self.ext
    local session_exists = vim.fn.filereadable(vim.fn.expand(session)) == 1
    if session_exists then
        local srouce_cmd = vim.api.nvim_parse_cmd("silent! source " .. session, {})
        vim.api.nvim_cmd(srouce_cmd, {})
    end
end

function Session:delete()
    local session = self.store .. self.name .. self.ext
    local session_exists = vim.fn.filereadable(vim.fn.expand(session)) == 1
    if session_exists then
        local rm_cmd = vim.api.nvim_parse_cmd("!rm " .. session, {})
        vim.api.nvim_cmd(rm_cmd, {})
    end
end

return Session
