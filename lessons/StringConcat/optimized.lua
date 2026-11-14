local M = {}

local concat = table.concat

function M.build_log(count, buf)
    if count <= 0 then
        return ""
    end

    buf = buf or {}
    for i = 1, count do
        buf[i] = "[tick=" .. i .. "] hit=25 crit=true\n"
    end
    return concat(buf, "", 1, count)
end

return M
