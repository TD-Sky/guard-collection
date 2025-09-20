local lint = require('guard.lint')

local function starts_with(s, prefix)
  return string.sub(s, 1, #prefix) == prefix
end

return {
  cmd = 'd2',
  stdin = true,
  fname = false,
  args = { 'validate', '-' },
  parse = function(result, bufnr)
    local diagnostics = {}

    for _, line in ipairs(vim.split(result, '\n')) do
      if starts_with(line, 'Success!') then
        return diagnostics
      elseif starts_with(line, 'err: ') then
        local row_str, col_str, diag = string.match(line, 'err: [^:]*: (%d+):(%d+): (.+)')
        if row_str and col_str and diag then
          local row = tonumber(row_str)
          local col = tonumber(col_str)

          table.insert(
            diagnostics,
            lint.diag_fmt(bufnr, row, col, diag, vim.diagnostic.severity.ERROR, '[d2]', row, col)
          )
        end
      end
    end

    return diagnostics
  end,
}
