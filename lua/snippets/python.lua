local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

return {
    s("imp", {
        t({"import "}),
        i(1)
    }),
    s("with", {
        t({"with "}),
        i(1),
        t({" as "}),
        i(2),
        t({"","\t"}),
    }),
    s("for", {
        t({"for "}),
        i(1),
        t({" in "}),
        i(2),
        t({":","\t"}),
    }),
    s("range", {
        t({"range("}),
        c(1, {
            sn(nil, {
                i(1),
                t({", "}),
                i(2),
            }),
            sn(nil, {
                i(1),
            }),
        }),
        t({")"}),
    }),
    s("ifmain", {
        t({"if __name__ == '__main__':", "\t"}),
    }),
}
