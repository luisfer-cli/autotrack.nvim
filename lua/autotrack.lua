local M = {}

local config = {
  enabled = true,
  task_name = "autotrack.nvim",
  exclude_filetypes = { "help", "qf", "netrw", "fugitive", "git" }
}

local current_tracking = nil

local function is_excluded_filetype(filetype)
  for _, excluded in ipairs(config.exclude_filetypes) do
    if filetype == excluded then
      return true
    end
  end
  return false
end

local function get_project_name()
  local cwd = vim.fn.getcwd()
  return vim.fn.fnamemodify(cwd, ":t")
end

local function get_git_branch()
  local handle = io.popen("git branch --show-current 2>/dev/null")
  if handle then
    local branch = handle:read("*a"):gsub("\n", "")
    handle:close()
    return branch ~= "" and branch or "no-git"
  end
  return "no-git"
end

local function get_file_language(filetype)
  if filetype == "" then
    return "plaintext"
  end
  return filetype
end

local function stop_tracking()
  if current_tracking then
    vim.fn.system("timew stop 2>/dev/null")
    current_tracking = nil
  end
end

local function start_tracking(filetype)
  if not config.enabled or is_excluded_filetype(filetype) then
    return
  end

  local project = get_project_name()
  local branch = get_git_branch()
  local language = get_file_language(filetype)
  
  local tags = {
    config.task_name,
    "project:" .. project,
    "branch:" .. branch,
    "lang:" .. language
  }
  
  local tag_string = table.concat(tags, " ")
  local cmd = string.format("timew start %s 2>/dev/null", tag_string)
  
  vim.fn.system(cmd)
  current_tracking = {
    project = project,
    branch = branch,
    language = language
  }
end

local function on_buffer_enter()
  local filetype = vim.bo.filetype
  
  if current_tracking then
    local new_project = get_project_name()
    local new_branch = get_git_branch()
    local new_language = get_file_language(filetype)
    
    if current_tracking.project ~= new_project or 
       current_tracking.branch ~= new_branch or 
       current_tracking.language ~= new_language then
      stop_tracking()
      start_tracking(filetype)
    end
  else
    start_tracking(filetype)
  end
end

local function setup_autocommands()
  local group = vim.api.nvim_create_augroup("AutoTrack", { clear = true })
  
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = group,
    callback = on_buffer_enter
  })
  
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = stop_tracking
  })
  
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function()
      vim.defer_fn(on_buffer_enter, 100)
    end
  })
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  setup_autocommands()
end

function M.start()
  config.enabled = true
  on_buffer_enter()
end

function M.stop()
  config.enabled = false
  stop_tracking()
end

function M.toggle()
  if config.enabled then
    M.stop()
  else
    M.start()
  end
end

function M.status()
  if current_tracking then
    print(string.format("Tracking: %s (project:%s branch:%s lang:%s)", 
      config.task_name,
      current_tracking.project,
      current_tracking.branch,
      current_tracking.language))
  else
    print("Not tracking")
  end
end

return M