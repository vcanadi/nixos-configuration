{ pkgs }:
let myExtraConfig = ''

  colorscheme lunaperche
  ri Normal guibg=NONE
  hi Normal ctermbg=16
  set background=light

  let g:mapleader = ','
  set nu
  set tabstop=2
  set shiftwidth=2
  set softtabstop=2
  set expandtab
  syntax on
  filetype plugin on
  set ignorecase
  set smartcase
  set hlsearch
  set noswapfile

" vim without plugins
  set path+=**
  set wildmode=longest,list,full
  set wildmenu
  set t_ut=
  set t_Co=256

  let g:netrw_banner=0        " disable annoying banner
  let g:netrw_browse_split=4  " open in prior window
  let g:netrw_altv=1          " open splits to the right
  let g:netrw_liststyle=3     " tree view
  let g:netrw_list_hide=netrw_gitignore#Hide()
  let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

  cabb W w
  cabb Q q

" plugin shortcuts

  " function! Jsonl()
  "   exe "%!jsonlint --sort preserve -f"
  "   exe ":set foldmethod=syntax"
  " endfunction
  " :command Jsonl call Jsonl()

  " setlocal foldmethod=syntax

  function! CloseTree()
    if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  endfunction

  function! NERDTreeToggleInCurDir()
    " If NERDTree is open in the current buffer
    if (exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1)
      exe ":NERDTreeClose"
    else
      if (expand("%:t") != "" )
         exe ":NERDTreeFind"
      else
        exe ":NERDTreeToggle"
      endif
    endif
  endfunction

  function! ToggleTree()
    if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | else | NERDTreeFind | endif
  endfunction

  nnoremap <leader>f :call NERDTreeToggleInCurDir()<CR>
  nnoremap <leader>z za

" os clipboard
  set clipboard=unnamedplus

" spell check
" set spell spelllang=en_us

  autocmd bufenter * call CloseTree()

  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

  highlight Pmenu ctermfg=0 ctermbg=100

  " Movement between windows
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>

  augroup BgHighlight
    autocmd!
    autocmd WinEnter * set cul
    autocmd WinLeave * set nocul
  augroup END

  autocmd BufWritePre * %s/\s\+$//e

  if has('persistent_undo')      "check if your vim version supports it
    set undofile                 "turn on the feature
    set undodir=$HOME/.vim/undo  "directory where the undo files will be stored
    endif

" fzf bindings
  map <Leader>r :Files<CR>

" ack binding
  map ; :Ag<space>

" COC

" floating window bg color
highligh CocFloating ctermbg=7


" GoTo code navigation.
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)

map <Leader>al <Plug>(coc-codeaction-line)
map <Leader>ac <Plug>(coc-codeaction-cursor)
map <Leader>ao <Plug>(coc-codelens-action)

nnoremap <Leader>kd :<C-u>CocList diagnostics<Cr>
nnoremap <Leader>kc :<C-u>CocList commands<Cr>
nnoremap <Leader>ko :<C-u>CocList outline<Cr>
nnoremap <Leader>kr :<C-u>CocListResume<Cr>

inoremap <silent><expr> <c-space> coc#refresh()

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

set signcolumn=yes

" TAB completion
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
'';
  in
{
  enable = true;
  viAlias = true;
  vimAlias = true;
  extraConfig = myExtraConfig;
  coc.enable = true;
  coc.settings = {
    "suggest" = {
      "noselect" = true;
      "enablePreview" = true;
      "enablePreselect" = false;
      "disableKind" = true;
      "snippetsSupport" = false;
    };
    "diagnostic" = {
      "virtualText" = true;
      "virtualTextCurrentLineOnly" = false;
      "virtualTextLines" = 1;
      "virtualTextPrefix" = " —— ";
    };
    "list.height" = 20;
    "codeLens.enable" = true;
    "coc.preferences.enableMarkdown" = true;
    "coc.preferences.jumpCommand" = "tab drop";
    languageserver.haskell = {
        command = "haskell-language-server-wrapper";
        args = [ "--lsp" ];
        rootPatterns = [
          "*.cabal"
          "stack.yaml"
          "cabal.project"
          "package.yaml"
          "hie.yaml"
        ];
        filetypes = [ "hs" "lhs" "haskell" "lhaskell" ];
        initializationOptions.languageServerHaskell = {
          hlintOn = true;
          maxNumberOfProblems = 10;
          completionSnippetsOn = true;
        };
    };
  };

  plugins = with pkgs.vimPlugins;  [
    commentary
    fugitive
    fzfWrapper
    fzf-vim
    ghcid
    haskell-vim
    coc-nvim
    coc-json
    coc-rls

    Syntastic
    nvim-lspconfig
    The_NERD_tree
    vim-gitgutter
    vim-nix
    agda-vim
    vim-lsp
  ];
}
