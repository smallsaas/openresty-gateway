local res = require("resty.etcd").new({protocol = "v3", http_host = "http://172.23.0.3:2379"}):set('/path/to/key', 'val', '')
local res = require("resty.etcd").new({protocol = "v3", http_host = "http://172.23.0.3:2379"}):get('/path/to/key')
print(res)