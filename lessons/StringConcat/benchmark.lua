local naive = require("lessons.StringConcat.naive")
local optimized = require("lessons.StringConcat.optimized")

local count = 5000
print(string.format("Running StringConcat benchmark (%d entries)...", count))

collectgarbage("collect")
collectgarbage("stop")
local m0 = collectgarbage("count")
local t0 = os.clock()
local s_naive = naive.build_log(count)
local time_naive = os.clock() - t0
local kb_naive = collectgarbage("count") - m0
collectgarbage("restart")

local buf = {}
optimized.build_log(count, buf) -- warmup

collectgarbage("collect")
collectgarbage("stop")
local m1 = collectgarbage("count")
local t1 = os.clock()
local s_opt = optimized.build_log(count, buf)
local time_opt = os.clock() - t1
local kb_opt = collectgarbage("count") - m1
collectgarbage("restart")

assert(s_naive == s_opt)

print(string.format("Naive (..):       %.4f s | GC allocated: %.2f KB", time_naive, kb_naive))
print(string.format("table.concat:     %.4f s | GC allocated: %.2f KB", time_opt, kb_opt))
if time_opt > 0 then
    print(string.format("Speedup:          %.2fx faster", time_naive / time_opt))
end
