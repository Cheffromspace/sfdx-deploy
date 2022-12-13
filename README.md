#SFDX Deploy for NeoVim
This script allows you to deploy the current file in NeoVim using the Salesforce DX command line interface (CLI).

Installation
Install the Salesforce DX CLI and make sure it is available on your system's PATH.
Save the sfdx_deploy.lua script to your NeoVim configuration directory (e.g. ~/.config/nvim/ on Linux or %LOCALAPPDATA%\nvim\ on Windows).
Usage
To deploy the current file using the SFDX CLI, open the file in NeoVim and run the following command:

`:lua require("sfdx_deploy").deploy_current_file()`
Alternatively, you can create a command by adding the following line to your .vimrc file:
`command! -nargs=0 SfdxDeploy lua require("sfdx_deploy").deploy_current_file()`
or in init.lua:
`vim.cmd("command! -nargs=0 SfdxDeploy lua require('sfdx_deploy').deploy_current_file()")``


This will allow you to deploy the current file by running the :SfdxDeploy command in NeoVim.

Any deployment errors will be added to a quickfix list in NeoVim, allowing you to easily view and navigate the errors.

License
This script is licensed under the MIT License. See LICENSE for more information.
