{ pkgs }:
{
  enable = true;
  viAlias = true;
  vimAlias = true;
  extraConfig = ''
      hi Normal guibg=NONE ctermbg=NONE
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

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    map <Leader>qf <Plug>(coc-fix-current)

    map <Leader>al <Plug>(coc-codeaction-line)
    map <Leader>ac <Plug>(coc-codeaction-cursor)
    map <Leader>ao <Plug>(coc-codelens-action)

    nnoremap <Leader>kd :<C-u>CocList diagnostics<Cr>
    nnoremap <Leader>kc :<C-u>CocList commands<Cr>
    nnoremap <Leader>ko :<C-u>CocList outline<Cr>
    nnoremap <Leader>kr :<C-u>CocListResume<Cr>

    " Add `:Format` command to format current buffer.
    command! -nargs=0 Format :call CocActionAsync('format')

    " Add `:OR` command for organize imports of the current buffer.
    command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

    inoremap <silent><expr> <c-space> coc#refresh()
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
      else
        execute '!' . &keywordprg . " " . expand('<cword>')
      endif
    endfunction


    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    '';

    coc.enable = true;
    coc.settings = {
      "suggest" = {
        "noselect" = false;
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
      languageserver = {
        haskell = {
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

      Syntastic
      nvim-lspconfig
      The_NERD_tree
      vim-gitgutter
      vim-nix
    ];
}
