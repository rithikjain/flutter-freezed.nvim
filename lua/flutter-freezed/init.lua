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

-- Freezed snippets
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

-- Run build runner on the current file
local jobId = -1
local infoBufferId = -1

local function createBuffer()
  infoBufferId = vim.api.nvim_create_buf(false, true)
  vim.cmd("vsplit")
  return infoBufferId
end

local function writeToBuffer(data)
  if data then
    -- Make it temporarily writable so we don't have warnings.
    vim.api.nvim_buf_set_option(infoBufferId, "readonly", false)
    -- Write to the buffer
    vim.api.nvim_buf_set_lines(infoBufferId, -1, -1, false, data)
    -- Make readonly again.
    vim.api.nvim_buf_set_option(infoBufferId, "readonly", true)
    -- Mark as not modified, otherwise you'll get an error when
    -- attempting to exit vim.
    vim.api.nvim_buf_set_option(infoBufferId, "modified", false)
  end
end

local function toggleBuffer()
  -- Check if the buffer is currently visible in any window
  local buf_visible = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == infoBufferId then
      buf_visible = true
      vim.api.nvim_win_close(win, true) -- Close the window to "hide" the buffer
      return
    end
  end

  -- If the buffer is not visible, open it in a vertical split
  if not buf_visible then
    vim.cmd('vsplit')                          -- Open a new vertical split
    vim.api.nvim_set_current_buf(infoBufferId) -- Set the buffer in the new split
  end
end

local function terminateJob()
  if jobId ~= -1 then
    vim.fn.jobstop(jobId)
    jobId = -1
    infoBufferId = -1
  else
    print("There is no job running")
  end
end

local function findPackageRoot()
  -- Look for the nearest pubspec.yaml
  local packageRoot = vim.fn.fnamemodify(vim.fn.findfile("pubspec.yaml", ".;"), ":h")
  return packageRoot ~= "" and packageRoot or nil
end

local function runBuildRunnerOnCurrentFile()
  if jobId ~= -1 then
    print("Job already in progress")
    return
  end

  local packageRoot = findPackageRoot()
  if not packageRoot then
    print("Not inside a Dart package!")
    return
  end

  local absoluteFilePath = vim.fn.expand('%:p')
  local filePathWithoutExtension = removeFileExtenstion(absoluteFilePath)

  createBuffer()
  vim.api.nvim_set_current_buf(infoBufferId)

  local buildRunnerCommand =
      "cd " .. packageRoot .. " && fvm dart run build_runner build --delete-conflicting-outputs --build-filter=" ..
      filePathWithoutExtension .. ".freezed.dart," .. filePathWithoutExtension .. ".g.dart"

  writeToBuffer({ buildRunnerCommand })

  jobId = vim.fn.jobstart(buildRunnerCommand,
    {
      stdout_buffered = false,
      on_stdout = function(_, data)
        if data then
          writeToBuffer(data)
        end
      end,
      on_stderr = function(_, data)
        if data then
          writeToBuffer(data)
        end
      end,
      on_exit = function(_, _)
        print("Build runner ran")
        jobId = -1
        infoBufferId = -1
      end
    })
end

M.runBuildRunnerOnCurrentFile = runBuildRunnerOnCurrentFile
M.toggleInfoBuffer = toggleBuffer
M.terminateJob = terminateJob

return M
