json = require('cjson')
table = require('table')

local requests = {}
table.insert(requests, {'/a'})
table.insert(requests, {'/b'})
table.insert(requests, {'/c'})

local result = {data = {}}

local responses = {ngx.location.capture_multi(requests)}
ngx.say(json.encode(responses))

--ngx.say(json.encode(result))
