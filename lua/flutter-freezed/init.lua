local M = {}

local ls = require("luasnip")
local extras = require("luasnip.extras")

local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local rep = extras.rep
local fmt = require("luasnip.extras.fmt").fmt

local function removeFileExtenstion(filename)
  local name = filename:match("(.*)%..-")
  return name or filename -- Return original if no extension found
end

local filename = function()
  return f(function(_, snip)
    return removeFileExtenstion(snip.snippet.env.TM_FILENAME)
  end)
end

ls.add_snippets("dart", {
  s("frc", fmt(
    [[
    @freezed
    class {} with _${} {{
      const factory {}() = _{};

      factory {}.fromJson(Map<String, dynamic> json) => _${}FromJson(json);
    }}
    ]],
    { i(1), rep(1), rep(1), rep(1), rep(1), rep(1) }
  )),
  s("frf", fmt(
    [[
    import 'package:freezed_annotation/freezed_annotation.dart';

    part '{}.freezed.dart';
    part '{}.g.dart';

    @freezed
    class {} with _${} {{
      const factory {}() = _{};

      factory {}.fromJson(Map<String, dynamic> json) => _${}FromJson(json);
    }}
    ]],
    { filename(), filename(), i(1), rep(1), rep(1), rep(1), rep(1), rep(1) }
  ))
})

return M
