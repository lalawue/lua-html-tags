
local Tags = require("html-tags")

local function htmlSpec()
    return {
        doctype { "html" },
        html {
            import "specs/head_spec.lua",
            h1 "hello",
            br,
            h2 { "world" },
            h3 {
                { class="center" },
                "morning",
            },
            div {
                { class="center mt-5 ml-3" },
                h2 "title",
                p "any thing content",
            }
        }
    }
end

local htmlString = [[
    return {
        doctype { "html" },
        html {
            --import "specs/head_spec.lua",
            h1 "hello",
            br,
            h2 { "world" },
            h3 {
                { class="center" },
                "morning",
            },
            div {
                { class="center mt-5 ml-3" },
                h2 "title",
                p "any thing content",
            }            
        }
    }
]]

local page_env = setmetatable({}, {
    __index = Tags.default_tags
})

print(Tags.render(page_env, htmlSpec))
--print(Tags.render(page_env, htmlString))