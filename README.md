
# About

[lua-html-tags](https://github.com/lalawue/lua-html-tags.git) was a Lua base DSL for writing HTML documents.

you can write HTML as write Lua code, and more simplify, you can add
your own tags / functions or variables into the source, make it really flexible for customize.

besides, all these tags / functions or variables, will not affect current function `_ENV` or `_G`, it will use its own function `_ENV` or `setfenv` all the time, even when `include` other source.

# Installl

through [LuaRocks](https://luarocks.org/)

```sh
$ luarocks install html-tags
```

or just put html-tags.lua into your project.

# Features

- pre defined most HTML 5 tags, and very easy to add your owns
- use its own function `_ENV` or `setfenv`, will not affect current one
- support `include` other sources
- support Lua 5.1 and obove

# Usage

## Basic

render function / string with pre-defined function or variable

```lua
local Tags = require("html-tags")

-- an example to add self defined tags / functions and variables
local outer_value = 5

local function calc_bc(b, c)
    return b + c + outer_value
end

-- define page scope tags / functions and variables below
local page_env = {
    title_name = " HTML-TAGS ",
    calc_abc = function(a, b, c)
        return tostring(a * calc_bc(b, c))
    end,
    tag_result = function(a)
        return "<p>" .. a .. ': ' .. tostring(calc_bc(1, 2)) .. "</p>\n"
    end,
}

-- function below only use _G and page_env as this function's _ENV or setfenv
local function htmlSpecs()
    return {
        doctype { "html" },
        html {
            -- you can include other sources
            include "test/head_tpl.lua",
            h1 { title_name },
            br,
            h2 "world", -- or `h2 { "world" }`
            { "<!-- raw line one -->\n", "<!-- raw line two -->\n" },
            h3 {
                --[[ if tag's parameter table 1st element was a table,
                treat it as attributes key / value pairs ]]
                { class="center" },
                "morning",
            },
            div {
                h2 "title",
                p { "result is: " .. calc_abc(2, 5, 10) }, -- 40 = 2 * (5 + 10 + 5)
                p { escape "<b>escape content</b> " },
            },
            tag_result "result"
        }
    }
end

-- render function or string with _ENV or setfenv
print(Tags.render(htmlSpec, page_env))
```

will output

```
<!DOCTYPE html>
<html>
<head>
<title> HTML-TAGS </title>
<meta src="2nd import level:  HTML-TAGS " />
<link rel="1st import level" />
</head>
<h1> HTML-TAGS </h1>
<br/>
<h2>world</h2>
<!-- raw line one -->
<!-- raw line two -->
<h3 class="center">morning</h3>
<div class="center mt-5 ml-3">
<h2>title</h2>
<p>result is: 40</p>
<p>&lt;b&gt;escape content&lt;/b&gt; 4</p>
</div>
<p>result: 8</p>
</html>
```

## Define & Register Tags

- define tag like other HTML one
- register to default tags

```lua
-- <!-- VALUE --!>
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

local function htmlPage()
    return {
        html {
            doctype "html",
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

print(Tags.render(htmlPage))
```

will output

```
<html>
<!DOCTYPE html>
<!-- 1st comment--!>
<!-- 2nd 3rd--!>
<!-- <div>empty box</div>
--!>
<fast-button>Click Me</fast-button>
<fast-button class="button-primary">Submit</fast-button>
</html>
```

## Nested Attributes

you can put tag attributes together, and very easy to conjunct key / value pairs.

```lua
local function htmlNestedAttributes()
    return {
        doctype "html",
        html {
            div {{"[class=center mt-3][class=ml-2]"}, -- same key will join
                a {{"[href=http://baidu.com][target=_blank]"},
                    "ClickMe"
                }
            }
        }
    }
end
```

will output

```
<!DOCTYPE html>
<html><div class="center mt-3 ml-2"><a href="http://baidu.com" target="_blank">ClickMe</a>
</div>
</html>
```

# Details

- only render function or string for setup _ENV or setfenv
- outer level function or string should return `table` as a block description
- every HTML 5 tag was a function, in Lua, you can call one `table` or `string` without paired parenthesis
- if tag's parameter and its first element is a `table`
  - if element table index 1 has string value, `gmatch` it as '[key1=value1]' attributes pairs
  - otherwise, `pair` this element table as tag's attributes key / value pairs
- it will evaluate every function, and combine every table into a whole page string
