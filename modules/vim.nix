{ pkgs }: 
with pkgs;
let 
  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;
  myPlugins = {
    haskell-vim = buildVimPlugin {
      name = "haskell-vim";
      src = fetchgit {
        url = "https://github.com/neovimhaskell/haskell-vim";
        rev = "6bb3716a41796f27321ee565b8bb36806b9f7b38";
        sha256 = "0rkhbzxb17rhxw9g7s47grnl10kxijph7x1b8b6ilzyzbnxaf3s5";
      };
      dependencies = [];
    };
  };
  myVimrcConfig = {
    customRC = ''

      let g:mapleader = ','
      set nu
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
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
      
      noremap <leader>b :VimShellInteractive nixos-rebuild switch <CR>
      noremap <leader>bb :VimShellInteractive stack --nix build <CR>

      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

      autocmd StdinReadPre * let s:std_in=1
      autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

      highlight Pmenu ctermfg=0 ctermbg=100

      nnoremap <C-J> <C-W><C-J>
      nnoremap <C-K> <C-W><C-K>
      nnoremap <C-L> <C-W><C-L>
      nnoremap <C-H> <C-W><C-H>

    '';
    
    vam = {
      knownPlugins = pkgs.vimPlugins // myPlugins;
      pluginDictionaries = [{
        names = [
          "Syntastic"
          "The_NERD_tree"
          "vimshell"
          "vim-nix"
          "vim-airline"
          "vim-airline-themes"
          "haskell-vim"
          # "youcompleteme"
          "ctrlp"
          "The_NERD_Commenter"
          "ack-vim"
          "vim-orgmode"

          "vimproc"
          "Hoogle"
        ];
      }];
    };
  };
in
{
  myVim = vim_configurable.customize {
    name = "vim";
    vimrcConfig = myVimrcConfig;
  };

  myNvim = pkgs.neovim.override {
    vimAlias = true;
    configure = myVimrcConfig; 
  };
}
