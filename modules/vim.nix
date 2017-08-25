with import <nixpkgs> {}; 

vim_configurable.customize {
    name = "vim";
    vimrcConfig.customRC = ''

        let g:mapleader = ','

      " line nbrs, whitespaces   
        set nu
        syntax enable 
 
      " plugin shortcuts
        " ctrlp 
        let g:ctrlp_map = '<c-p>'
        let g:ctrlp_cmd = 'CtrlP'
        let g:ctrlp_working_path_mode = 'ra'

      " NERDTree
        noremap <leader>f :NERDTreeToggle<CR>

      " os clipboard
        nmap <leader>y "*y
        vmap <leader>y "*y
          
    '';

    vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
    vimrcConfig.vam.pluginDictionaries = [{
        names = [
            "Syntastic"
            "ctrlp"
            "The_NERD_tree"
            "vim-nix"
            "ghcmod"
            "vimproc"
        ];
    }];
}
