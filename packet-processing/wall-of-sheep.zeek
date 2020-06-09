@load base/protocols/http

module WallOfSheep;

redef HTTP::default_capture_password = T;

export {
    redef enum Log::ID += { LOG };

    type Info: record {
        ts: time            &log;
        uid: string         &log;
        id: conn_id         &log;
        username: string    &log;
        password: string    &log;
        where_found: string &log;
    };

    # By default, credentials won't be redacted at all
    # If true, the first 4 characters of the password will be
    # shown but the rest will be redacted.
    const redact_passwords = F &redef;

    # max length of a POST body to parse    
    const max_body_len = 200 &redef;

    # different param names for username
    const username_params: set[string] = { "username", "user" } &redef;

    # different param names for password
    const password_params: set[string] = { "password", "pass" } &redef;
}

# track which creds have been found
type FoundCredLog: record {
    username: string;
    password: string;
    where_found: string;
};

global found_creds: set[FoundCredLog];

# add new POST body field to HTTP record (don't log it)
redef record HTTP::Info += {
    post_body: string &optional;
};

event zeek_init() &priority=5
    {
    Log::create_stream(WallOfSheep::LOG, [$columns=Info]);
    }

function log_creds(uid: string, id: conn_id, username: string, password: string, where_found: string)
    {
    # redact password
    if ( redact_passwords )
        {
        if ( |password| > 4 )
            {
            # there's enough content to partially redact
            password = password[:4] + gsub(password, /./, "*")[4:];
            }
        else
            {
            # there isn't enough to redact, just replace
            password = gsub(password, /./, "*");
            }
        }

    # check if creds have been logged yet
    local found: FoundCredLog = [$username=username,
                                 $password=password,
                                 $where_found=where_found];
    if ( found in found_creds )
        {
        return;
        }

    # creds haven't been seen yet, log them
    add found_creds[found];

    local log: Info = [$ts=network_time(),
                       $uid=uid,
                       $id=id,
                       $username=username,
                       $password=password,
                       $where_found=where_found];
        
    Log::write(WallOfSheep::LOG, log);
    }

# parse creds from GET or POST params
function save_creds_from_params(c: connection, params: string, where: string)
    {
    # save creds
    local username = "";
    local password = "";

    local param_vector = split_string(params, /&/);

    for ( idx in param_vector )
        {
        # param = "key=value"
        # split the param to get each part
        local param = param_vector[idx];
        local parts = split_string1(param, /=/);

        # make sure it has a value
        if ( |parts| != 2 )
            next;

        local key = parts[0];
        local value = parts[1];

        # check if we have a username or a password
        if ( key in username_params )
            username = value;
        else if ( key in password_params )
            password = value;

        # check if we have a username and a password
        # if so, log and return
        if ( username != "" && password != "" )
            {
            log_creds(c$uid, c$id, username, password, where);
            }
        }
    }

# This event is triggered when a new HTTP request is identified, it may not have any data yet
event http_request(c: connection, method: string, original_URI: string, unescaped_URI: string, version: string)
    {
    # check if there are GET parameters
    if ( /\?/ in unescaped_URI )
        {
        save_creds_from_params(c, split_string(unescaped_URI, /\?/)[1], "GET params");
        }
    }

# based on https://github.com/corelight/log-add-http-post-bodies/blob/master/scripts/main.bro#L16
event handle_http_post_bodies(f: fa_file, data: string)
    {
    for ( cid in f$conns )
        {
        local c: connection = f$conns[cid];

        # check if the record entry exists, if not, create it
        if ( ! c$http?$post_body )
            c$http$post_body = "";

        # stop if we've already gathered enough data
        if ( |c$http$post_body| > max_body_len )
            return;

        # save data
        # append b/c this can be called multiple times for the same conn
        c$http$post_body += data;
        if ( |c$http$post_body| > 200 )
            {
            c$http$post_body = c$http$post_body[0:max_body_len] + "...";
            }
        }
    }

# This event is triggered after an HTTP request is fully processed
event http_end_entity(c: connection, is_orig: bool)
    {
    # check for basic auth
    if ( c$http?$username && c$http?$password )
        {
        log_creds(c$uid, c$id, c$http$username, c$http$password, "Basic Auth");
        }

    # check for a post body
    if ( c$http?$post_body )
        {
        save_creds_from_params(c, unescape_URI(c$http$post_body), "POST params");
        }
    }

event file_over_new_connection(f: fa_file, c: connection, is_orig: bool)
    {
    # add POST parser
    if ( is_orig && c?$http && c$http?$method && c$http$method == "POST" )
        {
        Files::add_analyzer(f, Files::ANALYZER_DATA_EVENT, [$stream_event=handle_http_post_bodies]);
        }
    }