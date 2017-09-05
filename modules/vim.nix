with import <nixpkgs> {}; 

vim_configurable.customize {
    name = "vim";
    vimrcConfig.customRC = ''

        let g:mapleader = ','

      " line nbrs, whitespaces   
        set nu
        syntax enable 
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
          
    '';

    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
    vimrcConfig.vam.pluginDictionaries = [{
        names = [
            "Syntastic"
            "The_NERD_tree"
            "vim-nix"
            "vim-airline"
            "vim-airline-themes"

            "ghcmod"
            "vimproc"
            "Hoogle"
        ];
    }];
}
