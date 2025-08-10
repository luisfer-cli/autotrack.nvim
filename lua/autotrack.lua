local M = {}

local config = {
  enabled = true,
  task_name = "autotrack.nvim",
  exclude_filetypes = { "help", "qf", "netrw", "fugitive", "git" }
}

local current_tracking = nil

local cache = {
  project_name = nil,
  git_branch = nil,
  git_branch_timestamp = 0,
  excluded_filetypes = {}
}

local function build_excluded_cache()
  cache.excluded_filetypes = {}
  for _, excluded in ipairs(config.exclude_filetypes) do
    cache.excluded_filetypes[excluded] = true
  end
end

local function is_excluded_filetype(filetype)
  return cache.excluded_filetypes[filetype] == true
end

local function get_project_name()
  if not cache.project_name then
    local cwd = vim.fn.getcwd()
    cache.project_name = vim.fn.fnamemodify(cwd, ":t")
  end
  return cache.project_name
end

local function get_git_branch()
  local current_time = vim.loop.hrtime()
  if not cache.git_branch or (current_time - cache.git_branch_timestamp) > 5000000000 then
    local handle = io.popen("git branch --show-current 2>/dev/null")
    if handle then
      local branch = handle:read("*a"):gsub("\n", "")
      handle:close()
      cache.git_branch = branch ~= "" and branch or "no-git"
    else
      cache.git_branch = "no-git"
    end
    cache.git_branch_timestamp = current_time
  end
  return cache.git_branch
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
  
  if is_excluded_filetype(filetype) then
    if current_tracking then
      stop_tracking()
    end
    return
  end
  
  local new_project = get_project_name()
  local new_branch = get_git_branch()
  local new_language = get_file_language(filetype)
  
  if current_tracking and 
     current_tracking.project == new_project and
     current_tracking.branch == new_branch and 
     current_tracking.language == new_language then
    return
  end
  
  if current_tracking then
    stop_tracking()
  end
  start_tracking(filetype)
end

local function setup_autocommands()
  local group = vim.api.nvim_create_augroup("AutoTrack", { clear = true })
  
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = on_buffer_enter
  })
  
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = stop_tracking
  })
  
  vim.api.nvim_create_autocmd("DirChanged", {
    group = group,
    callback = function()
      cache.project_name = nil
      cache.git_branch = nil
      cache.git_branch_timestamp = 0
      on_buffer_enter()
    end
  })
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  build_excluded_cache()
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