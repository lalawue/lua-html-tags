package = "html-tags"
version = "0.1.20210829-1"
source = {
	url = "git+https://github.com/lalawue/lua-html-tags.git",
	tag = "0.1.20210829"
}
description = {
	summary = "Lua base DSL for writing HTML documents",
	detailed = "Lua base DSL for writing HTML documents",
	homepage = "https://github.com/lalawue/lua-html-tags.git",
	maintainer = "lalawue <suchaaa@gmail.com>",
	license = "X11/MIT"
}
dependencies = {
	"lua >= 5.1"
}
build = {
	type = "builtin",
	modules = {
		["html-tags"] = "html-tags.lua"
	}
} 
