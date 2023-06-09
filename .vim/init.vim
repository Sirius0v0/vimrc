" --------------------------------------------------------------------
"                            General Settings
" --------------------------------------------------------------------
set nocompatible        " 去掉对vi的兼容，让vim运行在完全模式下"
set encoding=utf-8      " 打开文件时编码格式"
set ignorecase          " 忽略大小写

" 仅检查文件最后一行是否有模式行
" 以实现对特定文件的个性化设置
" 需要对本配置页进行组织折叠
" 配置模式行 -> vim:foldmethod=marker:foldlevel=0
" 折叠部分用 {{{和}}} 进行包装
set modelines=1

" Tab相关设置
set expandtab           " tab输入为空格
set tabstop=4           " 读取tab字符显示的空格数
set softtabstop=4       " 编辑时tab输入的空格数
set shiftwidth=4        " 
set smartindent         " 智能缩进
set cinoptions=j1,(0,ws,Ws,g0

" 代码折叠
set foldmethod=syntax
set foldlevel=100

set laststatus=2
set number              " 显示行号
set ruler               " 显示光标行列号
set relativenumber      " 相对行号
set hlsearch            " 高亮匹配项
set incsearch           " 键入时搜索
set listchars=tab:▸\ ,trail:⋅,extends:❯,precedes:❮
set showbreak=↪
set list
set mouse=a
set timeout nottimeout ttimeoutlen=10

set undofile
if has('nvim')
    set undodir=/tmp//,.
    set backupdir=/tmp//,.
    set directory=/tmp//,.
else
    set undodir=/tmp//,.
    set backupdir=/tmp//,.
    set directory=/tmp//,.
endif

syntax on                   	" 开启语法高亮
filetype on                     " 开启文件类型检测
filetype plugin on              " 开启插件的支持
filetype indent on              " 开启文件类型相应的缩进规则

let mapleader="\<SPACE>"        " 改leader键为空格，默认为/


" --------------------------------------------------------------------
"                          Begin Plugin Lists
" --------------------------------------------------------------------

call plug#begin()

" ========== 功能性插件 ==========
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'liuchengxu/vim-which-key'

" ========== 美化方案 ==========
"Plug 'sainnhe/sonokai'
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
"Plug 'voldikss/vim-floaterm'

" ========== 代码辅助 ==========
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'puremourning/vimspector', {'do': './install_gadget.py --enable-c'}
Plug 'preservim/nerdcommenter'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'

call plug#end()

" --------------------------------------------------------------------
"                          End Plugin Lists
" --------------------------------------------------------------------

" Nerdtree Config Section {{{
" ======================== Begin Nerdtree Config ========================

nnoremap <leader>e :NERDTreeToggle<CR>

" }}}

" Coc.nvim Confing Section {{{
" ======================== Begin Coc.nvim Config ========================

" coc extensions
let g:coc_global_extensions = [
            \ 'coc-json',
            \ 'coc-cmake',
            \ 'coc-vimlsp'
            \ ]
set signcolumn=number
set updatetime=300
" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <leader>- <Plug>(coc-diagnostic-prev)
nmap <leader>= <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gD <Plug>(coc-definition)
nmap <silent> gd :tab sp<CR><Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
"autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <leader>d  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> gle  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> glc  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> glo  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> gls  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> glj  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> glk  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> glp  :<C-u>CocListResume<CR>

" }}}

" [disable]Sonokai Config Section {{{
" ======================== Begin Sonokai Config ========================

"" Important!!
"if has('termguicolors')
    "set termguicolors
"endif

"" The configuration options should be placed before `colorscheme sonokai`.
"let g:sonokai_style = 'andromeda'
"let g:sonokai_better_performance = 1
"colorscheme sonokai

" }}}

" CXX-Highlight Config Section {{{

hi default link LspCxxHlSymFunction cxxFunction
hi default link LspCxxHlSymFunctionParameter cxxParameter
hi default link LspCxxHlSymFileVariableStatic cxxFileVariableStatic
hi default link LspCxxHlSymStruct cxxStruct
hi default link LspCxxHlSymStructField cxxStructField
hi default link LspCxxHlSymFileTypeAlias cxxTypeAlias
hi default link LspCxxHlSymClassField cxxStructField
hi default link LspCxxHlSymEnum cxxEnum
hi default link LspCxxHlSymVariableExtern cxxFileVariableStatic
hi default link LspCxxHlSymVariable cxxVariable
hi default link LspCxxHlSymMacro cxxMacro
hi default link LspCxxHlSymEnumMember cxxEnumMember
hi default link LspCxxHlSymParameter cxxParameter
hi default link LspCxxHlSymClass cxxTypeAlias

" }}}

" Vimspector Config Section {{{
" ======================== Begin Vimspector Config ========================

let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
nmap <leader><ESC> :VimspectorReset<CR>
" F11与全屏冲突，更改步入步出为F12 | S-F12
nmap <F12> <Plug>VimspectorStepInto
nmap <S-F12> <Plug>VimspectorStepOut

nmap <leader>v <Plug>VimspectorBalloonEval
xmap <leader>v <Plug>VimspectorBalloonEval


" }}}

" Asyncrun Config Section {{{

let g:asyncrun_open = 6

" }}}

" Asynctasks Config Section {{{

let g:asynctasks_term_rows = 6 
let g:asynctasks_term_cols = 50
let g:asynctasks_term_reuse = 0
let g:asynctasks_term_focus = 0

nnoremap <F7> :AsyncTask project-build<CR>
nnoremap <C-F5> :AsyncTask project-run<CR>
nnoremap <leader>m :AsyncTask project-config<CR>

" }}}

" Vim-Which-Key Config Section {{{

nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> , :<c-u>WhichKey ','<CR>

" }}}

" LeaderF Config Section {{{

let g:Lf_HideHelp = 1
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_ShortcutF = ''

noremap ,F :Leaderf rg<CR>
noremap ,f :Leaderf file<CR>
noremap ,b :Leaderf! buffer<CR>

" }}}

" Gruvbox Config Section {{{

set bg=dark
colorscheme gruvbox

" }}}

" Lightline.vim Config Section {{{

set noshowmode
"let g:lightline = {}

" }}}

" --------------------------------------------------------------------
"                          Begin Custom Functions
" --------------------------------------------------------------------

" [Command]Create Debug Config {{{
function! s:generate_vimspector_config()
    if !filereadable('.vimspector.json')
        if &filetype == ('c' || 'cpp')
            tabe ./.vimspector.json
            0r ~/.vim/.vimspectorjson/cpp.json
        elseif &filetype == 'python'
            tabe ./.vimspector.json
            0r ~/.vim/.vimspectorjson/cpp.json
        endif
    else
        tabe .vimspector.json
    endif
endfunction

command! -nargs=0 GenVimspectorJson :call s:generate_vimspector_config() 
" }}}

" --------------------------------------------------------------------
"                          Begin Custom Functions
" --------------------------------------------------------------------

" vim:foldmethod=marker:foldlevel=0
