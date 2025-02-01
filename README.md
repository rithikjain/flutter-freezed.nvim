# flutter-freezed.nvim
An utility plugin for making life easier while using flutter freezed.

### What it does:

https://github.com/user-attachments/assets/b8298775-b526-488c-a02c-71b17fa33d28

- Provides useful macros for freezed.
    - frc - Generates the boilerplate for a freezed class
    - frf - Generated the boilerplate for a freezed file

- Lets you run build runner to generate freezed classes on single files.
    - FlutterFreezedGenForCurrentFile - Starts build runner for the current file in the buffer
    - FlutterFreezedStopGen - Stops the build runner in process
    - FlutterFreezedInfoToggle - Toggles the buffer that shows the logs of the build runner

### Sample config with lazy:
```
return {
  "rithikjain/flutter-freezed.nvim",
  dependencies = {
    "L3MON4D3/LuaSnip",
  },
  lazy = false,
  keys = {
    { "<leader>gf", "<cmd>FlutterFreezedGenForCurrentFile<CR>", desc = "Generate flutter freezed for the current file" },
    { "<leader>gi", "<cmd>FlutterFreezedInfoToggle<CR>",        desc = "Toggle flutter freezed generation info" },
    { "<leader>gx", "<cmd>FlutterFreezedStopGen<CR>",           desc = "Stop generating flutter freezed files" },
  },
}

```
