vim.api.nvim_exec(
  [[
set noshowmode
let g:lightline = { 'colorscheme': 'wombat', 'active': { 'left':  [ [ 'mode', 'paste' ], [ 'readonly', 'absolutepath', 'modified', ], [ 'cocstatus', ] ], 'right': [ [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ] }, 'component_function': { 'cocstatus': 'coc#status' }, }
]],
  false
)
