-- this script appends a auto-generated token to
-- the query string
--
-- query string is chosen as it helps in grep'ing
-- in the squid.blog
--
-- also upstream system can read it of the qs
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

function set_qs ()
    local key_str = 'token='

    -- test is the incoming qs exists
    if ( nil == ts.ctx [ 'qs' ] )
    then
        ts.debug ( 'incoming qs is nil' )
        -- ats would prefix '?' automatically
        return key_str ..
                gen_req_token ()
    else
        ts.debug ( 'incoming qs is ' .. ts.ctx [ 'qs' ] )
        -- append to incoming query string 
        return ts.ctx [ 'qs' ] ..
                '&' ..
                key_str  .. 
                gen_req_token ()
    end

    return 0
end

function do_remap ()
    -- store the incoming query string ( if any )
    -- in a table
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-ctx
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-get-uri-args
    ts.ctx [ 'qs' ] = ts.client_request.get_uri_args ()

    -- set the query string
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-set-uri-args
    ts.client_request.set_uri_args ( set_qs ( ) )

    return 0
end

-- vim: set ts=4 sts=4 sw=4 et:
