local M = {}

function M.build_log(count)
    if count <= 0 then
        return ""
    end

    local out = ""
    for i = 1, count do
        out = out .. "[tick=" .. i .. "] hit=25 crit=true\n"
    end
    return out
end

return M
