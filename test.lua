--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local Tags = require("html-tags")

local function htmlSpec()
    return {
        doctype { "html" },
        html {
            include "test/head_tpl.lua",
            h1 { title_name },
            br,
            h2 "world",
            { "<!-- raw line one -->\n", "<!-- raw line two -->\n" },
            h3 {
                { class="center" },
                "morning",
            },
            div {
                { class="center mt-5 ml-3" },
                h2 "title",
                p { "result is: " .. calc_abc(2, 5, 10) }, -- 40 = 2 * (5 + 10 + 5)
                p { escape "<b>escape content</b> " }
            }
        }
    }
end

local htmlString = [[
    return {
        doctype "html",
        html {
            include "test/head_tpl.lua",
            h1 { title_name },
            br,
            h2 { "world" },
            "<!-- only raw line one -->\n",
            h3 {
                { class="center" },
                { "another ", "morning" },
            },
            div {
                { class="center mt-5 ml-3" },
                h2 "title",
                p {
                    { result = calc_abc(3, 10, 15) },  -- 90 = 3 * (10 + 15 + 5)
                    "see attribute result",                    
                }
            }            
        }
    }
]]

local outer_value = 5

local function calc(b, c)
    return b + c + outer_value
end

local page_env = {
    title_name = " HTML-TAGS ",
    calc_abc = function(a, b, c)
        return tostring(a * calc(b, c))
    end
}

print("---- Loading Table ----")
print(Tags.render(htmlSpec, page_env))

print("\n---- Loading String ----")
print(Tags.render(htmlString, page_env))
