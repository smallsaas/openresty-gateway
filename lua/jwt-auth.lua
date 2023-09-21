-- Openresty 开发API文档：https://openresty-reference.readthedocs.io/en/latest/Lua_Nginx_API/

-- 使用cjson处理json
json = require('cjson')
-- JWT库
jwt = require('resty.jwt')
-- 校验器
validators = require('resty.jwt-validators')
-- 使用自定义table处理JSON复制
custom_table = require('lua.table-utils')

-- JWT 密钥
local jwt_key = os.getenv('JWT_KEY') or 'ZW1selpHOHVjSEp2WjNKbGMzTXVhWE53YjNKMGN3'

ngx.log(ngx.STDERR, '获取到JWT KEY：' .. jwt_key)

-- 请求Token
local token = ngx.var.http_Authorization

-- 防止令牌为空
if token == nil then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = 'application/json; charset=utf-8'
    ngx.say('{\"code\": 403, \"message\": \"Forbidden\"}')
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

-- 去除Token头
token = string.gsub(token, 'Bearer ', '', 1)
ngx.log(ngx.STDERR, '获取到Token信息：' .. token)

-- 校验期待配置
local claim_spec = {
    exp = validators.is_not_expired()
}

-- 执行校验
local jwt_obj = jwt:verify(jwt_key, token, claim_spec)
ngx.log(ngx.STDERR, '校验结果：' .. json.encode(jwt_obj))

-- 校验失败流程
if not jwt_obj['valid'] then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = 'application/json; charset=utf-8'
    ngx.say('{\"code\": 403, \"message\": \"INVALID_JWT\"}')
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

ngx.log(ngx.STDERR, 'Token：' .. token .. '校验通过')