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

  --if result.status == 0 then
  if result.status == 0 then
    vim.api.nvim_out_write(result.result.deployedSource[1].fileName .. " deployed successfully")
    return
  end


  -- Check for deployment status
  local status = result["status"]
  if status == nil or status ~= 1 then
    -- Deployment failed, so display an error message
    local message = "Deployment failed"
    if result["result"] ~= nil and result["result"]["status"] ~= nil then
      message = message .. ": " .. result["result"]["status"]
    end
    vim.api.nvim_err_writeln(message)
    return
  end

  -- Check for deployment errors
  local errors = result["result"]["deployedSource"]
  if errors ~= nil and #errors > 0 then
    -- Create the quickfix list
    local items = {}
    for _, error in pairs(errors) do
      -- Add the error to the quickfix list
      local item = {
        filename = error["filePath"] or "",
        lnum = error["lineNumber"] or 0,
        col = error["columnNumber"] or 0,
        text = error["error"] or "",
      }
      table.insert(items, item)
    end

    -- Set the quickfix list
    vim.api.nvim_call_function("setqflist", { items })

    -- Open the quickfix list
    vim.api.nvim_command("copen")
  else
    -- No errors were found, so display a message indicating success
    vim.api.nvim_out_write("Deployment succeeded\n")
  end
end

function DeployManifest()
  local project_root = find_project_root()

  -- Construct the command to run
  local command = 'sfdx force:source:deploy -x ' .. project_root .. '/manifest/package.xml --json'

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

  --if result.status == 0 then
  if result.status == 0 then
    vim.api.nvim_out_write(result.result.deployedSource[1].fileName .. " deployed successfully")
    return
  end

  -- Check for deployment status
  local status = result["status"]
  if status == nil or status ~= 1 then
    -- Deployment failed, so display an error message
    local message = "Deployment failed"
    if result["result"] ~= nil and result["result"]["status"] ~= nil then
      message = message .. ": " .. result["result"]["status"]
    end
    vim.api.nvim_err_writeln(message)
    return
  end

  -- Check for deployment errors
  local errors = result["result"]["deployedSource"]
  if errors ~= nil and #errors > 0 then
    -- Create the quickfix list
    local items = {}
    for _, error in pairs(errors) do
      -- Add the error to the quickfix list
      local item = {
        filename = error["filePath"] or "",
        lnum = error["lineNumber"] or 0,
        col = error["columnNumber"] or 0,
        text = error["error"] or "",
      }
      table.insert(items, item)
    end

    -- Set the quickfix list
    vim.api.nvim_call_function("setqflist", { items })

    -- Open the quickfix list
    vim.api.nvim_command("copen")
  else
    -- No errors were found, so display a message indicating success
    vim.api.nvim_out_write("Deployment succeeded\n")
  end
end

function Find_project_root()
  --get current file path
  local buf_path = vim.fn.expand('%:p:h')
  local dir = buf_path

  -- Keep going up the directory tree until we find the root folder
  while dir ~= '/' do
    -- Check if the current directory has a sfdx-project.json file or a .git folder
    if lfs.attributes(dir .. '/sfdx-project.json') or lfs.attributes(dir .. '/.git') then
      -- If we find either of these files, return the current directory as the project root
      return dir
    end

    -- Go up one level in the directory tree
    dir = dirname(dir)
  end

  -- If we reach the root directory without finding a project root, show an error message
  nvim_err_writeln('Error: Unable to find project root. Make sure you are in a project directory.')
end

-- Bind the function to a command
-- vim.api.nvim_command("command! DeployCurrentBuffer lua require'sfdx-deploy'DeployCurrentBuffer()")
-- vim.api.nvim_command("command! DeployManifest lua require'sfdx-deploy'DeployManifest()")

return { DeployCurrentBuffer = DeployCurrentBuffer, DeployManifest = DeployManifest }
