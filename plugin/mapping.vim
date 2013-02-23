let s:save_cpo = &cpo
set cpo&vim


function! <SID>pf_revert() "{{{
	let file = perforce#common#get_kk(expand("%"))
	if perforce#is_p4_have(expand("%"))
		let outs = perforce#pfcmds_new_outs('revert','',' -a '.file)
	else
		let outs = perforce#pfcmds_new_outs('revert','',file)
	endif
	call perforce#LogFile(outs)
endfunction "}}}

nnoremap <PLUG>(p4_revert)
			\ :<C-u>call <SID>pf_revert()<CR>|"

nnoremap <PLUG>(unite_p4_commit)
			\ :<C-u>Unite source -input=p4\ <CR>|"

nnoremap <PLUG>(p4_echo_client_data)
			\ :<C-u>echo " -p " . perforce#get_PFPORT() . " -c " . perforce#get_PFCLIENTNAME() . "\n" . perforce#get_PFCLIENTPATH()<CR>|"

nnoremap <PLUG>(p4_cd_clentpath)
			\ :<C-u>lcd perforce#get_PFCLIENTPATH<CR>|"

nnoremap <PLUG>(p4_filelog)
			\ :<C-u>call perforce#unite_args('p4_filelog')<CR>|"

nnoremap <PLUG>(p4_diff)
			\ :<C-u>call perforce#unite_args('p4_diff')<CR>|"

nnoremap <PLUG>(p4_find)
			\ :<C-u>call perforce#pfFind()<CR>|"

nnoremap <PLUG>(p4_get_depot)
			\ :<C-u>let @+ = perforce#get_depot_from_path(expand("%:p"))<CR>|"

nmap ;cl<CR> <PLUG>(p4_echo_client_data)
nmap ;cr<CR> <PLUG>(p4_cd_clentpath)
nmap ;ff<CR> <PLUG>(p4_find)
nmap ;pl<CR> <PLUG>(p4_filelog)
nmap ;pd<CR> <PLUG>(p4_diff)
nmap ;pr<CR> <PLUG>(p4_revert)
nmap ;id<CR> <PLUG>(p4_get_depot)

nmap ;pe<CR> :<c-u>PfEdit<CR>
nmap ;pE<CR> :<c-u>PfAdd<CR>
nmap ;wd<CR> :<c-u>PfDiff<CR>

nnoremap ;pi<CR>  :<C-u>Unite p4_info<CR>|"
nnoremap ;pt<CR>  :<C-u>Unite p4_clients<CR>|"
nnoremap ;pc<CR>  :<C-u>Unite p4_changes_pending<CR>|"
nnoremap ;ps<CR>  :<C-u>Unite p4_changes_submitted<CR>|"
nnoremap ;po<CR>  :<C-u>Unite p4_opened<CR>|"
nnoremap ;pj<CR>  :<C-u>Unite p4_jobs<CR>|"
nnoremap ;ph<CR>  :<C-u>Unite p4_have<CR>|"
nnoremap ;pa<CR>  :<C-u>Unite p4_annotate<CR>|"
nnoremap ;pC<CR>  :<C-u>Unite p4_changes_pending_reopen<CR>|"
nnoremap ;pte<CR> :<C-u>Unite p4_template<CR>|"

nnoremap ;pp<CR> :<C-u>call unite#start([['settings_ex', 'g:unite_pf_data']])<CR>|"

let &cpo = s:save_cpo
unlet s:save_cpo

