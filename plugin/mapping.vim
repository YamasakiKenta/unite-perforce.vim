let s:save_cpo = &cpo
set cpo&vim

nnoremap <PLUG>(unite_p4_commit)
			\ :<C-u>Unite source -input=p4\ <CR>|"

nnoremap <PLUG>(p4_echo_client_data)
			\ :<C-u>echo " -p " . perforce#get#PFPORT() . " -c " . perforce#get#PFCLIENTNAME() . "\n" . perforce#get#PFCLIENTPATH()<CR>|"

nnoremap <PLUG>(p4_cd_clentpath)
			\ :<C-u>lcd <C-r>=perforce#get#PFCLIENTPATH()<CR><CR>|"

nnoremap <PLUG>(p4_filelog)
			\ :<C-u>call perforce#unite_args('p4_filelog')<CR>|"

nnoremap <PLUG>(p4_diff)
			\ :<C-u>call perforce#unite_args('p4_diff')<CR>|"

nnoremap <PLUG>(p4_find)
			\ :<C-u>call perforce#pfFind()<CR>|"

nnoremap <PLUG>(p4_get_depot)
			\ :<C-u>let @+ = perforce#get#depot#from_path(expand("%:p"))<CR>|"

let &cpo = s:save_cpo
unlet s:save_cpo
