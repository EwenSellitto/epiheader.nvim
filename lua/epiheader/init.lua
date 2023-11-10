local M = {} -- M stands for module, a naming convention

-- Function to get the root directory name (where .git is located)
local function get_root_dir_name()
  local root_dir = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print "Not a git repository"
    return ""
  end
  return root_dir:match "^.+/(.+)$"
end

-- Function to get the comment string based on the filetype
local function get_comment_string()
  local commentstring = vim.bo.commentstring

  if commentstring == "" then
    print "Comment format not found for current filetype"
    return nil, nil
  end

  local start_comment, end_comment = commentstring:match "^(.*)%%s(.*)$"
  if not end_comment or end_comment == "" then
    end_comment = start_comment -- Use single line comment format for both start and end
  end
  return start_comment, end_comment
end

-- Function to add the header
function M.add_header()
  local year = os.date "%Y"
  local root_dir_name = get_root_dir_name()
  local filename = vim.fn.expand "%:t" -- Only the current file name
  local start_comment, end_comment = get_comment_string()
  local spacer

  if start_comment == nil then
    return
  elseif start_comment == end_comment or end_comment == "" or not end_comment then
    start_comment = string.gsub(start_comment, " ", "")
    start_comment = start_comment .. start_comment
    end_comment = start_comment
    spacer = start_comment
  else
    spacer = "**"
  end

  if root_dir_name == "" or start_comment == nil then
    return
  end

  local header_lines = {
    start_comment,
    spacer .. " EPITECH PROJECT, " .. year,
    spacer .. " " .. root_dir_name,
    spacer .. " File description:",
    spacer .. " " .. filename,
  }
  if end_comment ~= start_comment then
    table.insert(header_lines, end_comment)
  else
    table.insert(header_lines, start_comment)
  end
  table.insert(header_lines, "")

  vim.api.nvim_buf_set_lines(0, 0, 0, false, header_lines)
end

function M.setup(_)
  vim.keymap.set("n", "<leader>eh", M.add_header, { desc = "epitech header creation" })
end

return M