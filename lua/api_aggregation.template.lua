-- Openresty 开发API文档：https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

-- 使用cjson处理json
json = require('cjson')
-- 使用table处理储存请求
table = require('table')

-- 获取请求参数值
-- GET
-- local args = ngx.req.get_uri.args()
-- POST
-- local args = ngx.req.get_post_args()

-- 请求集合
local requests = {}
-- POST格式：table.insert(请求集合, {'请求路径', { method = ngx.HTTP_POST, body = 'hello' }})
-- GET格式： table.insert(请求集合, {'请求路径', { args = 'a=3&b=4' }})
-- 默认采用GET请求
table.insert(requests, {'/api'})

-- 最终响应结果
local result = {data = {}}

-- 根据请求集合发起多个请求并获取响应结果
-- issue all the requests at once and wait until they all return
local responses = {ngx.location.capture_multi(requests)}

-- loop over the responses table
for i, resp in ipairs(responses) do
    -- process the response table "resp"
    if resp and resp.status == ngx.HTTP_OK then
        result.data[i] = resp.body:gsub('\n[^\n]*$', '')
    else
        result.data[i] = 'error'
    end
end

-- 返回接口聚合内容
ngx.say(json.encode(result))
