--  this is a simple lua script meant to use used with the
--  apache traffic server lua plugin
--  
--  https://github.com/apache/trafficserver/tree/master/plugins/experimental/ts_lua
--
-- the script extracts the scheme and domain from the referer header
-- and send it back as the Access-Control-Allow-Origin header

-- will help in grep'ing in traffic.out
script_tag = "[cors] "

-- this func would be invoked by the hook
-- it'll insert the header in the response
function send_cors_hdr ()
    local __func__ = "send_cors_hdr" 

    ts.debug ( script_tag .. __func__ .. ": start")

    if ts.ctx [ 'ref_hdr' ] ~= nil then
        ts.debug ( script_tag .. __func__ .. ": received referer: " .. ts.ctx [ 'ref_hdr' ] )

        -- extract the scheme and domain from the referer header
        -- note this is not implementing any whitelist
        -- but it can be done easily
        local fragment = string.match ( ts.ctx [ 'ref_hdr' ], '^https?://[a-z0-9.]+'  )
        ts.debug ( script_tag .. __func__ .. ": send_cors_hdr fragment: " .. fragment )

        ts.client_response.header [ 'Access-Control-Allow-Origin' ] = fragment
    else
        ts.debug ( script_tag .. __func__ .. ": received null referer header" )
    end

    ts.debug ( script_tag .. __func__ .. ": end")
    return 0
end

-- realize remap
-- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#description
function do_remap ()
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-header-header
    local __func__ = "do_remap" 
    local referer = ts.client_request.header.Referer

    ts.debug ( script_tag .. __func__ .. ": start")

    if referer == nil then 
        ts.ctx [ 'ref_hdr' ] = nil
        ts.debug ( script_tag .. __func__ .. ": received null referer header" )
    else
        ts.ctx [ 'ref_hdr' ] = referer 
        ts.debug ( script_tag .. __func__ .. ": received referer: " .. referer )
    end

    -- adding callback func send_cors_hdr () to the response hook 
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-hook
    ts.hook ( TS_LUA_HOOK_SEND_RESPONSE_HDR, send_cors_hdr )

    ts.debug ( script_tag .. __func__ .. ": end")
    return 0
end

-- vim: set sw=4 ts=4 et :
