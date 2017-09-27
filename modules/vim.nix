with import <nixpkgs> {}; 

vim_configurable.customize {
    name = "vim";
    vimrcConfig.customRC = ''

        let g:mapleader = ','

      " line nbrs, whitespaces   
        set nu
        set tabstop=2
        set shiftwidth=2
        set softtabstop=2
        set expandtab
        syntax on 
        filetype plugin on
 
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
        
        noremap <C-b> :VimShellInteractive nixos-rebuild switch <CR>

        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

        autocmd StdinReadPre * let s:std_in=1
        autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

        autocmd StdinReadPre * let s:std_in=1
        autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

    '';

    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
    vimrcConfig.vam.pluginDictionaries = [{
        names = [
            "Syntastic"
            "The_NERD_tree"
            "vimshell"
            "vim-nix"
            "vim-airline"
            "vim-airline-themes"
            "haskell-vim"
            "vim-addon-completion"
            "ctrlp"
            "The_NERD_Commenter"

            "ghcmod"
            "vimproc"
            "Hoogle"
        ];
    }];
}
