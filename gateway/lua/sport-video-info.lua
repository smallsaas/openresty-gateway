-- Openresty 开发API文档：https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

-- 使用cjson处理json
json = require('cjson')
-- 使用table处理储存请求
table = require('table')
http = require('resty.http')
function table.copy(t)
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

ngx.req.read_body()
local request_body = table.copy(json.decode(ngx.req.get_body_data()))
-- 视频存放路径
local fileUrl = (request_body.vidoSrc[0] or request_body.vidoSrc[1]).fileUrl
-- 获取视频详情
local resp = ngx.location.capture('/sport/api/ai/coach/video_info', {args = 'video_url=' .. fileUrl})
-- 请求成功时追加BODY参数
if resp.status == 200 then
    request_body['vidoDuration'] = json.decode(resp.body).video_play_duration
end
-- 提交新建信息
resp =
    ngx.location.capture(
    '/api/crud/coachingAction/coachingActions',
    {method = ngx.HTTP_POST, body = json.encode(request_body)}
)
ngx.say(resp.body)
