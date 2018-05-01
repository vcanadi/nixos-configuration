{ pkgs }:
with pkgs;
let
  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;
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
      set smartcase
      set hlsearch
      set incsearch
      set noswapfile

    " vim without plugins
      set path+=**
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
      nmap <leader>y "*y
      vmap <leader>y "*y
      nmap <leader>d "*d
      vmap <leader>d "*d
      nmap <leader>p "*p
      vmap <leader>p "*p

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

      colorscheme github
    '';

    packages.myVimPackage = with pkgs.vimPlugins; {
      # loaded on launch
      start = [
          calendar
          ctrlp
          fugitive
          haskell-vim
          neocomplete
          stylish-haskell
          Syntastic
          The_NERD_Commenter
          The_NERD_tree
          vim-addon-completion
          vim-airline
          vim-airline-themes
          vim-colorschemes
          vim-nix
          vim-orgmode
          vim-speeddating
          vimproc
          vimshell
    ];
      # manually loadable by calling `:packadd $plugin-name`
      opt = [ ];
      # To automatically load a plugin when opening a filetype, add vimrc lines like:
      # autocmd FileType php :packadd phpCompletion
    };

  };
in
{
  myNvim = pkgs.neovim.override {
    vimAlias = true;
    configure = myVimrcConfig;
  };
}
