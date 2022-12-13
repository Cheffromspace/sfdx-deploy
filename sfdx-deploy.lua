-- Save this file as "sfdx_deploy.lua" in your neovim configuration directory

local sfdx = require("sfdx")

local function deploy_current_file()
  -- Get the current file's path
  local current_file = vim.api.nvim_get_current_file()

  -- Run the sfdx force:source:deploy command
  local output = sfdx.force_source_deploy({
    json = true,
    sourcepath = current_file,
  })

  -- Parse the command output to find any deployment errors
  local errors = {}
  for line in output:gmatch("[^\r\n]+") do
    local error_message = line:match('"error": "([^"]+)"')
    if error_message then
      table.insert(errors, error_message)
    end
  end

  -- Build a quickfix list from the errors
  local quickfix_list = {}
  for _, error_message in ipairs(errors) do
    table.insert(quickfix_list, {
      filename = current_file,
      lnum = 1,
      col = 1,
      text = error_message,
      type = "E",
    })
  end

  -- Set the quickfix list in neovim
  vim.api.nvim_set_qflist(quickfix_list)
end

--define force_source_deploy
local function force_source_deploy(args)
  local command = "sfdx force:source:deploy"
  for key, value in pairs(args) do
    command = command .. " --" .. key .. " " .. value
  end
  return vim.fn.system(command)
end

--create a command to deploy the current file
vim.cmd("command! -nargs=0 SfdxDeploy lua deploy_current_file()")

--bind to leader dd
--vim.api.nvim_set_keymap("n", "<leader>dd", ":SfdxDeploy<CR>", { noremap = true, silent = true })
