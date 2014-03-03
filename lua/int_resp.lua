--  this is a simple lua script meant to use used with the
--  apache traffic server lua plugin
--  
--  https://github.com/apache/trafficserver/tree/master/plugins/experimental/ts_lua
--
-- the script intercepts the requests
-- and sends back small static files from the disk 
--
-- https://github.com/apache/trafficserver/blob/master/plugins/experimental/ts_lua/example/test_server_intercept.lua

function send_file ()
    ts.debug ( 'send_file start' )

    -- get the request path
    -- https://trafficserver.readthedocs.org/en/latest/reference/plugins/ts_lua.en.html#ts-client-request-get-uri
    local uri = ts.client_request.get_uri ()

    ts.debug ( 'received header:' .. uri )
    ts.debug ( 'send_file stop' )

    -- prefix path
    -- open file handle explicitly
    -- as we want to handle error cases ourselves

    -- highly dangerous usage
    -- when uri *must* be filtered
    -- a "../../" styled path can take you to any directory
    -- and all files readable by the "nobody" could be read out  
    local file_handle = io.open ( '/var/www/html' .. uri )

    if  file_handle == nil then
        ts.debug ( 'file does not exist' )

        body = 'Not Found'
        local resp = 'HTTP/1.1 404 Not Found\r\n' ..
                     'Content-Length: ' .. string.len ( body ) .. '\r\n' ..
                     'Content-Type: text/plain\r\n\r\n' ..
                     body 
        ts.debug ( 'returning 404' )
        return resp

    else
        -- "*a": reads the whole file, starting at the current position. On end of file, it returns the empty string.
        -- http://www.lua.org/manual/5.1/manual.html#5.7
        local body = file_handle:read ( '*a' )

        -- remember to close the file handle
        file_handle:close ()

        local resp = 'HTTP/1.1 200 OK\r\n' ..
                 'Content-Length: ' .. string.len ( body ) .. '\r\n' ..
                 'Content-Type: text/plain\r\n\r\n' ..
                 body 
        return resp

    end

end

function do_remap ()
    ts.debug ( 'do_remap start' )
    -- incercept and put a callback to send_file ()
    ts.http.server_intercept ( send_file )
    ts.debug ( 'do_remap end' )

    return 0
end

-- vim: set et sw=4 ts=4 sts=4:
