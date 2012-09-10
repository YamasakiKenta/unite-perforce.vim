function! s:pf_edit() "{{{
	let file = perforce#common#Get_kk(expand("%"))
	if perforce#is_p4_have(expand("%"))
		let datas = perforce#pfcmds('edit','',file)
	else
		let datas = perforce#pfcmds('add','',file)
	endif
	call perforce#LogFile(datas)
endfunction "}}}
function! s:pf_revert() "{{{
	let file = perforce#common#Get_kk(expand("%"))
	if perforce#is_p4_have(expand("%"))
		let datas = perforce#pfcmds('revert','',' -a '.file)
	else
		let datas = perforce#pfcmds('revert','',file)
	endif
	call perforce#LogFile(datas)
endfunction "}}}

nnoremap <PLUG>(p4_edit)
			\ :<C-u>call <SID>pf_edit()<CR>|"

nnoremap <PLUG>(p4_revert)
			\ :<C-u>call <SID>pf_revert()<CR>|"

nnoremap <PLUG>(unite_p4_commit)
			\ :<C-u>Unite source -input=p4\ <CR>|"

nnoremap <PLUG>(p4_diff_tool)
			\ :<C-u>call perforce#pfDiff(expand("%"))<CR>|"  

nnoremap <PLUG>(p4_echo_client_data)
			\ :<C-u>echo $PFPORT . " - " . $PFCLIENTNAME . " - " . $PFCLIENTPATH<CR>|"

nnoremap <PLUG>(p4_print_info)
			\ :<C-u>call perforce#LogFile(perforce#pfcmds('info',''))<CR>|"

nnoremap <PLUG>(p4_cd_clentpath)
			\ :<C-u>lcd $PFCLIENTPATH<CR>|"

nnoremap <PLUG>(p4_filelog)
			\ :<C-u>call perforce#unite_args('p4_filelog')<CR>|"

nnoremap <PLUG>(p4_diff)
			\ :<C-u>call perforce#unite_args('p4_diff')<CR>|"

nnoremap <PLUG>(p4_find)
			\ :<C-u>call perforce#pfFind()<CR>|"

nmap ;up<CR> <PLUG>(unite_p4_commit)
nmap ;wd<CR> <PLUG>(p4_diff_tool)
nmap ;cl<CR> <PLUG>(p4_echo_client_data)
nmap ;cr<CR> <PLUG>(p4_cd_clentpath)
nmap ;ff<CR> <PLUG>(p4_find)
nmap ;pl<CR> <PLUG>(p4_filelog)
nmap ;pd<CR> <PLUG>(p4_diff)
nmap ;pe<CR> <PLUG>(p4_edit)
nmap ;pr<CR> <PLUG>(p4_revert)

nnoremap ;pi<CR> :<C-u>Unite p4_info<CR>|"
nnoremap ;pp<CR> :<C-u>Unite p4_settings<CR>|"
nnoremap ;pt<CR> :<C-u>Unite p4_clients<CR>|"
nnoremap ;pc<CR> :<C-u>Unite p4_changes_pending<CR>|"
nnoremap ;ps<CR> :<C-u>Unite p4_changes_submitted<CR>|"
nnoremap ;po<CR> :<C-u>Unite p4_opened<CR>|"
nnoremap ;pj<CR> :<C-u>Unite p4_jobs<CR>|"
nnoremap ;ph<CR> :<C-u>Unite p4_have<CR>|"
nnoremap ;pa<CR> :<C-u>Unite p4_annotate<CR>|"
nnoremap ;pC<CR> :<C-u>Unite p4_changes_pending_reopen<CR>|"
