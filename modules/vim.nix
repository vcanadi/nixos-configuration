{ pkgs }:
with pkgs;
let
  customPlugins.w3m = pkgs.vimUtils.buildVimPlugin {
    name = "w3m";
    src = pkgs.fetchFromGitHub {
      owner = "yuratomo";
      repo = "w3m.vim";
      rev = "228a852b188f1a62ecea55fa48b0ec892fa6bad7";
      sha256 = "0c06yipsm0a1sxdlhnf41lifhzgimybra95v8638ngmr8iv5dznf";
    };
  };

  myVimrcConfig = {
    customRC = ''
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
      set incsearch
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
      nnoremap <leader>f :NERDTreeToggle<CR>

    " os clipboard
      set clipboard=unnamedplus

      au BufRead /tmp/psql.edit.* set syntax=sql

      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

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

      let g:deoplete#enable_at_startup = 1

      if has('persistent_undo')      "check if your vim version supports it
        set undofile                 "turn on the feature
        set undodir=$HOME/.vim/undo  "directory where the undo files will be stored
        endif
    '';

    packages.myVimPackage = with pkgs.vimPlugins; {
      # loaded on launch
      start = [
          calendar
          ctrlp
          commentary
          deoplete-nvim
          fugitive
          haskell-vim
          # intero-neovim
          neocomplete
          open-browser
          vim-stylish-haskell
          Syntastic
          tagbar
          The_NERD_tree
          vim-addon-mru
          vim-airline
          vim-airline-themes
          vim-colorschemes
          vim-nix
          vim-orgmode
          vim-speeddating
          vimproc
          vimshell
      ];

    };
    vam = {
      knownPlugins = pkgs.vimPlugins // customPlugins; # optional
      pluginDictionaries = [
        { name = "w3m"; }
      ];
    };
  };
in
{
  myNvim = pkgs.neovim.override {
    vimAlias = true;
    configure = myVimrcConfig;
  };
}
