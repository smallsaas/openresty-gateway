-- Openresty 开发API文档：https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

-- 使用cjson处理json
json = require('cjson')
-- 使用table处理储存请求
table = require('table')
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
-- 请求体
local request_body = table.copy(json.decode(ngx.req.get_body_data()))
-- 请求方法
local request_method = ngx.req.get_method()
-- 视频链接
local vidoSrc = json.decode(request_body.vidoSrc)

if 'POST' == request_method then
    -- 视频存放路径
    local fileUrl = (vidoSrc[0] or vidoSrc[1]).fileUrl
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
elseif 'PUT' == request_method then
    -- ID
    local id = request_body.id
    -- 动作列表
    local items = request_body.items
    -- 视频存放路径
    local fileUrl = (vidoSrc[0] or vidoSrc[1]).fileUrl

    if id == nil or fileUrl == nil then
        ngx.say('参数缺失')
        return
    end

    -- 遍历处理动作列表
    for i, item in ipairs(items) do
        if item.framePosition ~= nil then
            -- 请求获取新建动作的帧画面URL
            local resp =
                ngx.location.capture(
                '/sport/api/ai/coach/posemodel?frame_position=' .. item.framePosition .. '&video_url=' .. fileUrl
            )
            if resp.status == 200 then
                -- 设置帧URL
                item['poseModelImage'] = json.decode(resp.body).data
            end
        end
    end

    -- 提交聚合后的信息
    resp =
        ngx.location.capture(
        '/api/crud/coachingAction/coachingActions/' .. id,
        {method = ngx.HTTP_PUT, body = json.encode(request_body)}
    )

    ngx.say(resp.body)
end
