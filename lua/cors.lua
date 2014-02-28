--  this is a simple lua script meant to use used with the
--  apache traffic server lua plugin
--  
--  https://github.com/apache/trafficserver/tree/master/plugins/experimental/ts_lua
--
-- the script extracts the scheme and domain from the referer header
-- and send it back as the Access-Control-Allow-Origin header

-- will help in grep'ing in traffic.out
script_tag = "[cors]"

-- this func would be invoked by the hook
-- it'll insert the header in the response
function send_cors_hdr ()
    if ts.ctx [ 'ref_hdr' ] ~= nil then
        ts.debug ( script_tag .. "send_cors_hdr recieved referer: " .. ts.ctx [ 'ref_hdr' ] )
        ts.client_response.header [ 'Access-Control-Allow-Origin' ] = string.sub ( ts.ctx [ 'ref_hdr' ], 0, -2 )
    else
        ts.debug ( script_tag .. "recieved null referer header" )
    end

    return 0
end

-- realize remap
-- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#description
function do_remap ()
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-header-header
    local referer = ts.client_request.header.Referer

    if referer == nil then 
        ts.ctx [ 'ref_hdr' ] = nil
        ts.debug ( script_tag .. "recieved null referer header" )
    else
        ts.debug ( script_tag .. "do_remap recieved referer: " .. referer )
    end

    -- adding callback func send_cors_hdr () to the response hook 
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-hook
    ts.hook ( TS_LUA_HOOK_SEND_RESPONSE_HDR, send_cors_hdr )

    return 0
end

-- vim: set sw=4 ts=4 et :
