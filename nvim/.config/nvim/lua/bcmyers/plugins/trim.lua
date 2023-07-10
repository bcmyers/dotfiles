local status, trim = pcall(require, "trim")
if not status then
  return
end

trim.setup(
  {
    ft_blocklist = {},
    patterns = {},
    trim_first_line = true,
    trim_last_line = true,
    trim_on_write = true,
    trim_trailing = true
  }
)

-- Commands

-- :TrimToggle
-- Toggle trim on save.

-- :Trim
-- Trim the buffer right away.
