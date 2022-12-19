-- Define the function that will be called when the plugin is run
function DeployCurrentBuffer()
  -- Get the path to the current buffer
  local buffer_path = vim.api.nvim_buf_get_name(0)
  if buffer_path == nil then
    return
  end

  -- Construct the command to run
  local command = 'sfdx force:source:deploy --sourcepath ' .. buffer_path .. ' --json'

  -- Run the command and get the output
  local handle = io.popen(command)
  local output = handle:read("*a")
  handle:close()

  -- Parse the JSON output
  local success, result = pcall(vim.fn.json_decode, output)
  if not success then
    -- JSON decoding failed, so there was an error with the command
    vim.api.nvim_err_writeln("Error running command: " .. command)
    return
  end

  -- Check for deployment errors
  local errors = result["result"]["error"]
  if errors ~= nil then
    -- Create the quickfix list
    local items = {}
    for _, error in pairs(errors) do
      -- Add the error to the quickfix list
      local item = {
        filename = error["fileName"],
        lnum = error["lineNumber"],
        col = error["columnNumber"],
        text = error["problem"],
      }
      table.insert(items, item)
    end

    -- Set the quickfix list
    vim.api.nvim_call_function("setqflist", { items })
  else
    -- No errors were found, so display a message indicating success
    vim.api.nvim_out_write("Deployment succeeded\n")
  end
end

-- Bind the function to a command
vim.api.nvim_command("command! DeployCurrentBuffer lua require'sfdx-deploy'DeployCurrentBuffer()")

return DeployCurrentBuffer
