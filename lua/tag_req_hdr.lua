-- this script adds a auto-generated token to
-- the X-Req-Tag header sent to the origin server (o.s.)
--
-- will need custom loggin %<{X-Req-Tag}cqh>
-- https://trafficserver.readthedocs.org/en/latest/admin/working-log-files.en.html#using-the-custom-format
--
-- also upstream system can read it of the header 
-- and tag the log messages with it

-- for date / time
require 'os'

-- this function generates a
-- unique token for each request
function gen_req_token ()
    -- separator
    local sep = '-'

    -- get client's ip address ( ipv4 / ipv6 )
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-client-addr-get-addr
    local ip, port, family = ts.client_request.client_addr.get_addr ()

    -- form the token string
    local token = ip .. sep ..
                ts.client_request.header.Host .. sep ..
                os.date ( "%m-%d-%Y-%H:%M:%S" )

    ts.debug ( 'generated token is ' .. token )
    return token
end

function do_remap ()
    local hdr_name  = 'X-Req-Tag'

    -- set the header before sending the request to o.s.
    ts.client_request.header [ hdr_name ] = gen_req_token () 

    return 0
end

-- vim: set ts=4 sts=4 sw=4 et:
