{ pkgs }:
with pkgs;
let
  myVimrcConfig = {
    customRC = ''
      colorscheme github

      let g:mapleader = ','
      set nu
      set tabstop=4
      set shiftwidth=4
      set softtabstop=4
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

      let g:netrw_banner=0        " disable annoying banner
      let g:netrw_browse_split=4  " open in prior window
      let g:netrw_altv=1          " open splits to the right
      let g:netrw_liststyle=3     " tree view
      let g:netrw_list_hide=netrw_gitignore#Hide()
      let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

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
      map <C-p> :Files<CR>

    " ack binding
      map ; :Ack<space>

    '';

    packages.myVimPackage = with pkgs.vimPlugins; {
      # loaded on launch
      start = [
          ack-vim                # Search in project
          calendar
          commentary
          deoplete-nvim
          fugitive
          fzfWrapper
          fzf-vim                # Search files (ctrlp replacement)
          haskell-vim
          neocomplete
          open-browser
          Syntastic
          tagbar
          The_NERD_tree
          vim-stylish-haskell
          vim-airline
          vim-airline-themes
          vim-colorschemes
          vim-gitgutter
          vim-nix
          vimproc
          vimshell
      ];

    };
  };
in
rec {
  myNvim = pkgs.neovim.override {
    vimAlias = true;
    configure = myVimrcConfig;
  };
}
