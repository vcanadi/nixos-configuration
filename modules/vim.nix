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

    " LSP bindings
      let g:LanguageClient_autoStart = 1

      let g:LanguageClient_serverCommands = {
          \ 'haskell': ['haskell-language-server', '--lsp'],
          \ }
      nnoremap <F5> :call LanguageClient_contextMenu()<CR>
      map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
      map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
      map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
      map <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
      map <Leader>lb :call LanguageClient#textDocument_references()<CR>
      map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
      map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>

    '';

    plugins = with pkgs.vimPlugins;  [
          commentary
          fugitive
          fzfWrapper
          fzf-vim
          ghcid
          haskell-vim
          Syntastic
          LanguageClient-neovim
          The_NERD_tree
          vim-airline
          vim-airline-themes
          vim-colorschemes
          vim-gitgutter
          vim-nix
      ];
}
