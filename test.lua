--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local Tags = require("html-tags")

do
    -- function below only use _G and page_env as _ENV or setfenv
    local function htmlSpec()
        return {
            doctype { "html" },
            html {
                -- you can include other template tags
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
                    h2 "title",
                    p { "result is: " .. calcABC(2, 5, 10) }, -- 40 = 2 * (5 + 10 + 5)
                    p { escape "<b>escape content</b> " },
                },
                tagResult "result"
            }
        }
    end

    -- string below will using loadstring() or load() to compile chunk as a function,
    -- and only use _G and page_env as _ENV or setfenv
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
                    h2 "title",
                    p {
                        { result = calcABC(3, 10, 15) },  -- 90 = 3 * (10 + 15 + 5)
                        "see attribute result",
                    },
                },
                tagResult "result"
            }
        }
    ]]

    local outer_value = 5

    local function calcBC(b, c)
        return b + c + outer_value
    end

    local page_env = {
        title_name = " HTML-TAGS ",
        calcABC = function(a, b, c)
            return tostring(a * calcBC(b, c))
        end,
        tagResult = function(a)
            return "<p>" .. a .. ': ' .. tostring(calcBC(1, 2)) .. "</p>\n"
        end,
    }

    print("---- Loading Table ----")
    print(Tags.render(htmlSpec, page_env))

    print("\n---- Loading String ----")
    print(Tags.render(htmlString, page_env))
end

do
    print("\n---- Register Tags ----")

    -- <!-- VALUE -->
    local tag_comment = function(value)
        return '<!--' .. Tags.tagExec(value, ' ') .. '--!>\n'
    end

    -- <fast-button ATTRIBUTES> CONTENT </fast-button>
    local fast_button = function(value)
        return '<fast-button' .. Tags.tagExec(value, '>') .. "</fast-button>\n"
    end

    Tags.tagRegister({
        ["comment"] = tag_comment,
        ["fast_button"] = fast_button
    })

    local function htmlNewPage()
        return {
            doctype "html",
            html {
                comment "1st comment",
                comment { "2nd ", "3rd" },
                comment {
                    div "empty box"
                },
                fast_button "Click Me",
                fast_button {{class="button-primary"},
                    "Submit"
                }
            }
        }
    end

    print(Tags.render(htmlNewPage))
end

do
    print("\n---- Nested Attributes ----")
    local function htmlNestedAttributes()
        return {
            doctype "html",
            html {
                div {{"[class=center mt-3][class=ml-2]"},
                    a {{"[href=http://baidu.com][target=_blank]"},
                        "ClickMe"
                    }
                }
            }
        }
    end

    print(Tags.render(htmlNestedAttributes))
end

