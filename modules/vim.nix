{ pkgs }:
with pkgs;
let
  customPlugins.vimpyter = pkgs.vimUtils.buildVimPlugin {
    name = "vimpyter";
    src = pkgs.fetchFromGitHub {
      owner = "szymonmaszke";
      repo = "vimpyter";
      rev = "master";
      sha256 = "0h4xbiqk6gdi2kiywjqkgf042n48wbqs2ha94swha4rcsi046py8";
    };
  };

  myVimrcConfig = {

    customRC = ''
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
      map ; :Ag<space>

      let python_highlight_all=1
      let g:LanguageClient_serverCommands = {
        \ 'python': ['pyls']
        \ }
       nnoremap <F5> :call LanguageClient_contextMenu()<CR>
       nnoremap <silent> gh :call LanguageClient_textDocument_hover()<CR>
       nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
       nnoremap <silent> gr :call LanguageClient_textDocument_references()<CR>
       nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
       nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
       nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>
    '';

    packages.myVimPackage = with pkgs.vimPlugins; {
      # loaded on launch
      start = [
          ag
          calendar
          commentary
          deoplete-nvim
          fugitive
          fzfWrapper
          fzf-vim                # Search files (ctrlp replacement)
          ghcid
          haskell-vim
          neocomplete
          open-browser
          Syntastic
          tagbar
          LanguageClient-neovim
          The_NERD_tree
          # vim-stylishask
          vim-airline
          vim-airline-themes
          vim-colorschemes
          vim-flake8
          vim-gitgutter
          vim-nix
          vim-scala
          vimproc
          vimshell
          w3m
          idris-vim
      ];

    };

    vam = {
      knownPlugins = pkgs.vimPlugins // customPlugins; # optional
      pluginDictionaries = [
        # { name = "vimpyter"; }
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
