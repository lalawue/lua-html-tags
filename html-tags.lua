--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local fType = type
local fString = tostring
local fConcat = table.concat
local ipairs = ipairs
local pairs = pairs
local setfenv = setfenv
local getfenv = getfenv
local xpcall = xpcall
local loadstring = loadstring
local load = load
local require = require
local loadfile = loadfile

local source_page_env = {}

-- execute function or table, output string
local function fExec(value, stag, etag)
    stag = stag or ""
    etag = etag or ""
    if fType(value) == "function" then
        return fExec(value())
    end
    if fType(value) ~= "table" then
        return stag .. fString(value and value or "") .. etag
    end
    local content = {}
    for i, t in ipairs(value) do
        if i == 1 then
            if fType(t) == "table" then
                for k, v in pairs(t) do
                    content[#content + 1] = " " .. k .. '="' .. v .. '"'
                end
                content[#content + 1] = stag
            else
                content[#content + 1] = stag .. fExec(t)
            end
        else
            content[#content + 1] = fExec(t)
        end
    end
    return fConcat(content, "") .. etag
end

-- one tag with exclamation before
local function fExclam(tag, value)
    return "<!" .. tag .. " " .. fExec(value, nil, ">\n")
end

-- one tag with dash behide
local function fOne(tag, value)
    return "<" .. tag .. fExec(value, nil, "/>\n")
end

-- two tag surround
local function fTwo(tag, value)
    local etag = (fType(value) == "table" and #value > 2) and ">\n" or ">"
    return "<" .. tag .. fExec(value, etag) .. "</" .. tag .. ">\n"
end

-- trace back function
local function fTraceBack(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. fString(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

-- set env to function
local function fSetFuncEnv(f, env)
    if _VERSION == "Lua 5.1" then
        return setfenv(f, env)
    end
    local i = 1
    repeat
        local n, v = debug.getupvalue(f, i)
        if n == "_ENV" then
            return debug.setupvalue(f, i, env)
        end
    until n == nil
end

-- model default tags
local default_tags = {
    import = function(value)
        if fType(value) ~= "string" then
            return "<!-- only support import string path -->"
        end
        local f, err = loadfile(value)
        if not f then
            return "<!-- failed to import: " .. fString(err) .. " -->\n"
        end
        fSetFuncEnv(f, source_page_env)
        local st, t = xpcall(f, fTraceBack)
        if not st then
            return "<!-- failed to import: " .. value .. ", error: " .. fString(t) .. " -->\n"
        end
        return fExec(t)
    end
}
setmetatable(default_tags, {__index = _G})

-- tags definition
local h5_tags = {
    doctype = 0,
    --[[        
    ]]
    area = 1,
    base = 1,
    br = 1,
    col = 1,
    command = 1,
    embed = 1,
    hr = 1,
    img = 1,
    input = 1,
    keygen = 1,
    link = 1,
    meta = 1,
    param = 1,
    source = 1,
    track = 1,
    wbr = 1,
    hr = 1,
    --[[        
    ]]
    a = 2,
    abbr = 2,
    address = 2,
    article = 2,
    aside = 2,
    audio = 2,
    b = 2,
    bdi = 2,
    bdo = 2,
    blockquote = 2,
    body = 2,
    button = 2,
    canvas = 2,
    caption = 2,
    cite = 2,
    code = 2,
    colgroup = 2,
    data = 2,
    datalist = 2,
    dd = 2,
    del = 2,
    details = 2,
    dfn = 2,
    div = 2,
    dl = 2,
    dt = 2,
    em = 2,
    fieldset = 2,
    figcaption = 2,
    figure = 2,
    footer = 2,
    form = 2,
    h1 = 2,
    h2 = 2,
    h3 = 2,
    h4 = 2,
    h5 = 2,
    h6 = 2,
    head = 2,
    header = 2,
    hgroup = 2,
    html = 2,
    i = 2,
    iframe = 2,
    ins = 2,
    kbd = 2,
    label = 2,
    legend = 2,
    li = 2,
    main = 2,
    map = 2,
    mark = 2,
    menu = 2,
    meter = 2,
    nav = 2,
    noscript = 2,
    object = 2,
    ol = 2,
    optgroup = 2,
    option = 2,
    output = 2,
    p = 2,
    pre = 2,
    progress = 2,
    q = 2,
    rb = 2,
    rp = 2,
    rt = 2,
    rtc = 2,
    ruby = 2,
    s = 2,
    samp = 2,
    script = 2,
    section = 2,
    select = 2,
    small = 2,
    span = 2,
    strong = 2,
    style = 2,
    sub = 2,
    summary = 2,
    sup = 2,
    table = 2,
    tbody = 2,
    td = 2,
    template = 2,
    textarea = 2,
    tfoot = 2,
    th = 2,
    thead = 2,
    time = 2,
    title = 2,
    tr = 2,
    u = 2,
    ul = 2,
    var = 2,
    video = 2
}

-- prepare default tags
for k, v in pairs(h5_tags) do
    if v == 2 then
        default_tags[k] = function(value)
            return fTwo(k, value)
        end
    elseif v == 1 then
        default_tags[k] = function(value)
            return fOne(k, {value})
        end
    else
        default_tags[k] = function(value)
            return fExclam(k:upper(), value)
        end
    end
end

return {
    -- renter function or string with page_env, return string or false with error message
    render = function(value, page_env)
        local func, emsg

        if fType(value) == "function" then
            func = value
        elseif fType(value) == "string" then
            func, emsg = (loadstring or load)(value)
            if not func then
                return false, "failed to load string: " .. fString(emsg)
            end
        end
        if fType(func) == "function" then
            page_env = (fType(page_env) == "table") and page_env or {}
            setmetatable(page_env, {__index = default_tags})
            source_page_env = page_env
            fSetFuncEnv(func, page_env)
            local st, t = xpcall(func, fTraceBack)
            if st then
                t = fExec(t)
                source_page_env = nil
                return t
            end
            emsg = t
        else
            emsg = "invalid param type, only support table or string: " .. fType(value)
        end
        return false, ("failed to render: " .. fString(emsg))
    end
}
