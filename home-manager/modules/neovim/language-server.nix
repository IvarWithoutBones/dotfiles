{ config
, pkgs
, lib
, ...
}:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      clang-tools # C/C++
      shellcheck # Bash

      # Rust
      cargo
      rustfmt
      rustc
    ];

    coc = {
      enable = true;

      settings = {
        client.snippetSupport = true;

        suggest = {
          enablePreview = true;
          noselect = true;
          enablePreselect = false;
        };

        languageserver = {
          nix = {
            command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
            filetypes = [ "nix" ];
            rootPatterns = [ "flake.lock" "flake.nix" ];
          };

          python = {
            command = "${pkgs.python3Packages.python-lsp-server}/bin/pylsp";
            filetypes = [ "python" ];
          };

          bash = {
            command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
            filetypes = [ "sh" "bash" ];
            args = [ "start" ];
          };

          rust = {
            command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            filetypes = [ "rust" ];
            rootPatterns = [
              "Cargo.toml"
              "Cargo.lock"
            ];
          };

          clangd = {
            command = "${pkgs.clang-tools}/bin/clangd";
            rootPatterns = [ "CMakeLists.txt" ];
            extraArgs = [ "--background-index" ];
            compilationDatabasePath = "build/compile_commands.json";

            filetypes = [
              "c"
              "cpp"
              "objc"
              "objcpp"
            ];
          };

          cmake = {
            command = "${pkgs.cmake-language-server}/bin/cmake-language-server";
            filetypes = [ "cmake" ];
            rootPatterns = [ "CMakeLists.txt" ];

            initializationOptions = {
              buildDirectory = "build";
            };
          };
        };
      };
    };

    extraConfig = ''
      set signcolumn=number
      set updatetime=300

      " Show all diagnostics.
      nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
      " Manage extensions.
      nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
      " Show commands.
      nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
      " Find symbol of current document.
      nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
      " Search workspace symbols.
      nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
      " Do default action for next item.
      nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
      " Do default action for previous item.
      nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
      " Resume latest coc list.
      nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
      " Format the currently open buffer
      nnoremap <silent><nowait> <space>f  :<C-u>CocCommand editor.action.formatDocument<cr>
      " Run the suggested action
      nnoremap <silent><nowait> <space> <Plug>(coc-codeaction-selected)

      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      nmap <silent> rn <Plug>(coc-rename)

      inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
      inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

      function! CheckBackspace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      " Make <CR> to accept selected completion item or notify coc.nvim to format
      " <C-g>u breaks current undo, please make your own choice.
      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"


      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Use K to show documentation in preview window.
      nnoremap <silent> K :call <SID>show_documentation()<CR>
      inoremap <silent><expr> <c-space> coc#refresh()

      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        elseif (coc#rpc#ready())
          call CocActionAsync('doHover')
        else
          execute '!' . &keywordprg . " " . expand('<cword>')
        endif
      endfunction
    '';
  };
}
