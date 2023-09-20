-- 使用table处理储存请求
table = require('table')
-- 自定义table模块
custom_table = {}

function custom_table.copy(t)
    local res = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            -- 递归解决多层table
            res[k] = table.copy(v)
        else
            res[k] = v
        end
    end
    return res
end

return custom_table