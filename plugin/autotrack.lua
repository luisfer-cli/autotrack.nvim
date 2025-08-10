if vim.g.loaded_autotrack then
  return
end
vim.g.loaded_autotrack = 1

vim.api.nvim_create_user_command("AutotrackStart", function()
  require("autotrack").start()
end, {})

vim.api.nvim_create_user_command("AutotrackStop", function()
  require("autotrack").stop()
end, {})

vim.api.nvim_create_user_command("AutotrackToggle", function()
  require("autotrack").toggle()
end, {})

vim.api.nvim_create_user_command("AutotrackStatus", function()
  require("autotrack").status()
end, {})