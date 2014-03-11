-- this is similar to
-- https://github.com/bh45k4r/ats/blob/master/lua/cors.lua
--
-- it echos back the incoming Origin header
-- for OPTIONS http method calls
--
-- http://en.wikipedia.org/wiki/Cross-Origin_Resource_Sharing#How_CORS_works

function send_cors_opt ()
    ts.debug ( 'got origin header ' .. ts.ctx [ 'origin_hdr' ] )

    local fragment = string.match ( ts.ctx [ 'origin_hdr' ], '^https?://[^/]+' )
    ts.debug ( 'setting cors header with ' .. fragment )

    ts.client_response.header [ 'Access-Control-Allow-Origin' ] = fragment

    return 0
end

function do_remap ()
    local method    = 'OPTIONS'
    local hdr_name  = 'Origin'

    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-get-method
    if method == ts.client_request.get_method ()
    then

        ts.debug ( 'method is ' .. method )

        if nil ~= ts.client_request.header [ hdr_name ]
        then
            ts.ctx [ 'origin_hdr' ] = ts.client_request.header [ hdr_name ]
            ts.hook ( TS_LUA_HOOK_SEND_RESPONSE_HDR, send_cors_opt )
        end

    end

    return 0
end

-- vim: set sts=4 sw=4 ts=4 et:
