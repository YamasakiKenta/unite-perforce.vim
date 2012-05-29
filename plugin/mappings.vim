nnoremap <Plug>(unite_p4_commit)
			\ :<C-u>Unite source -input=p4\ <CR>|"
nnoremap <Plug>(p4_diff_tool)
			\ :<C-u>call perforce#pfDiff(expand("%"))<CR>|"  
nnoremap <Plug>(p4_echo_client_data)
			\ :<C-u>echo $PFCLIENTNAME . " - " . $PFCLIENTPATH<CR>|"
nnoremap <Plug>(p4_print_info)
			\ :<C-u>call perforce#LogFile(perforce#pfcmds('info',''))<CR>|"
nnoremap <Plug>(p4_revert)
			\ :<C-u>call perforce#LogFile(perforce#pfcmds('revert -a "<C-r>=expand("%:p")<CR>"',''))<CR>|"

nmap ;up<CR> <Plug>(unite_p4_commit)
nmap ;wd<CR> <Plug>(p4_diff_tool)
nmap ;cl<CR> <Plug>(p4_echo_client_data)
nmap ;pi<CR> <Plug>(p4_print_info)

nnoremap ;ff<CR> :<C-u>call perforce#pfFind()<CR>|"
nnoremap ;pl<CR> :<C-u>call perforce#unite_args('p4_filelog')<CR>|"
nnoremap ;pd<CR> :<C-u>call perforce#unite_args('p4_diff')<CR>|"

nnoremap ;pp<CR> :<C-u>Unite p4_settings<CR>|"

nnoremap ;pt<CR> :<C-u>Unite p4_clients<CR>|"
nnoremap ;pc<CR> :<C-u>Unite p4_changes_pending<CR>|"
nnoremap ;ps<CR> :<C-u>Unite p4_changes_submitted<CR>|"
nnoremap ;po<CR> :<C-u>Unite p4_opened<CR>|"
nnoremap ;pj<CR> :<C-u>Unite p4_jobs<CR>|"
nnoremap ;ph<CR> :<C-u>Unite p4_have<CR>|"
nnoremap ;pa<CR> :<C-u>Unite p4_annotate<CR>|"
nnoremap ;pC<CR> :<C-u>Unite p4_changes_pending_reopen<CR>|"

nmap ;pe<CR> :<C-u>call <SID>pf_edit()<CR>|"
nmap ;pr<CR> :<C-u>call <SID>pf_revert()<CR>|"

function! s:pf_edit() "{{{
	let file = perforce#Get_kk(expand("%"))
	if perforce#is_p4_have(expand("%"))
		let datas = perforce#pfcmds('edit','',file)
	else
		let datas = perforce#pfcmds('add','',file)
	endif
	call perforce#LogFile(datas)
endfunction "}}}
function! s:pf_revert() "{{{
	let file = perforce#Get_kk(expand("%"))
	if perforce#is_p4_have(expand("%"))
		let datas = perforce#pfcmds('revert','',' -a '.file)
	else
		let datas = perforce#pfcmds('revert','',file)
	endif
	call perforce#LogFile(datas)
endfunction "}}}
