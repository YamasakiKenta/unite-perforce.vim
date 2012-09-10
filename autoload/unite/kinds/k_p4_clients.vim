function! unite#kinds#k_p4_clients#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_clients
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_clients',
			\ 'default_action' : 'a_p4_client',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\}
call unite#define_kind(s:kind)

let s:kind.action_table.a_p4_client_set = {
			\ 'description' : 'クライアントの変更', 
			\ }
function! s:kind.action_table.a_p4_client_set.func(candidates) "{{{

	" 保存する名前の取得
	let clname = a:candidates.action__clname
	let port   = a:candidates.action__port
	let clpath = perforce#get_ClientPathFromName(clname)

	" 作成するファイルの名前の保存 ( 切り替え ) 
	call perforce#set_PFCLIENTNAME(clname)
	call perforce#set_PFCLIENTPATH(clpath)
	call perforce#set_PFPORT(port)

	echo $PFCLIENTNAME
endfunction "}}}

let s:kind.action_table.a_p4_client_sync = { 
			\'is_selectable' : 1,
			\'description' : '最新同期', 
			\}
function! s:kind.action_table.a_p4_client_sync.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port
		exe '!start p4 -P '.port.' -c '.clname.' sync'
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_client_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'クライアントの情報 ( info ) ',
			\ }
function! s:kind.action_table.a_p4_client_info.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port

		" 各クライアントごとに表示する
		call perforce#common#LogFile(port.'_'.clname, 0)
		let outs = perforce#pfcmds('info', '-p '.port.' -c '.clname)
		call append(0,outs)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_client = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'クライアントの情報 ( client )',
			\ }
function! s:kind.action_table.a_p4_client.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port

		" 各クライアントごとに表示する
		call perforce#common#LogFile(clname, 0)
		let outs = perforce#pfcmds('client', '-p '.port, '-o '.clname)
		call append(0,outs)
	endfor
endfunction "}}}
