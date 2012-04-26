nnoremap <Plug>(unite_p4_commit)
			\ :<C-u>Unite source -input=p4\ <CR>|"
nnoremap <Plug>(p4_diff_tool)
			\ :<C-u>call perforce#pfDiff(expand("%"))<CR>|"  
nnoremap <Plug>(p4_echo_client_data)
			\ :<C-u>echo $PFCLIENTNAME . " - " . $PFCLIENTPATH<CR>|"
nnoremap <Plug>(p4_print_info)
			\ :<C-u>call perforce#LogFile(perforce#cmds('info'))<CR>|"
nnoremap <Plug>(p4_edit)
			\ :<C-u>call perforce#LogFile(perforce#cmds('edit "<C-r>=expand("%:p")<CR>"'))<CR>|"
nnoremap <Plug>(p4_revert)
			\ :<C-u>call perforce#LogFile(perforce#cmds('revert -a "<C-r>=expand("%:p")<CR>"'))<CR>|"

nmap ;up<CR> <Plug>(unite_p4_commit)
nmap ;wd<CR> <Plug>(p4_diff_tool)
nmap ;cl<CR> <Plug>(p4_echo_client_data)
nmap ;pi<CR> <Plug>(p4_print_info)
nmap ;pe<CR> <Plug>(p4_edit)
nmap ;pr<CR> <Plug>(p4_revert)

nmap ;ff<CR> :<C-u>call perforce#pfFind()<CR>|"
nmap ;pl<CR> :<C-u>call perforce#unite_args('p4_filelog')<CR>|"
nmap ;pd<CR> :<C-u>call perforce#unite_args('p4_diff')<CR>|"

nmap ;pt<CR> :<C-u>Unite p4_clients<CR>|"
nmap ;pc<CR> :<C-u>Unite p4_changes_pending<CR>|"
nmap ;ps<CR> :<C-u>Unite p4_changes_submitted<CR>|"
nmap ;po<CR> :<C-u>Unite p4_opened<CR>|"
nmap ;pj<CR> :<C-u>Unite p4_jobs<CR>|"
nmap ;ph<CR> :<C-u>Unite p4_have<CR>|"
nmap ;pa<CR> :<C-u>Unite p4_annotate<CR>|"

