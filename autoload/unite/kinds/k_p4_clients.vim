let s:_file  = expand("<sfile>")
let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('Unite-perforce.vim')
let s:Perforce = s:V.import('Mind.Perforce')
"
"
function! unite#kinds#k_p4_clients#define()
	return s:kind_clients
endfunction


let s:kind_clients = {
			\ 'name' : 'k_p4_clients',
			\ 'default_action' : 'a_p4_client',
			\ 'action_table' : {},
			\}
let s:kind_clients.action_table.a_p4_client_set = {
			\ 'description' : 'クライアントの変更', 
			\ }
function! s:kind_clients.action_table.a_p4_client_set.func(candidates) "{{{

	" 保存する名前の取得
	let clname = a:candidates.action__clname
	let port   = matchstr(a:candidates.action__port, '\(-p\s*\)*\zs.*')

	" 作成するファイルの名前の保存 ( 切り替え ) 
	call perforce#set#PFCLIENTNAME(clname)
	call perforce#set#PFPORT(port)
	call s:Perforce.get_client_root(1)

endfunction
"}}}

let s:kind_clients.action_table.a_p4_client_sync = { 
			\'is_selectable' : 1,
			\'description' : '最新同期', 
			\}
function! s:kind_clients.action_table.a_p4_client_sync.func(candidates) "{{{
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port
		exe '!start p4 '.port.' -c '.clname.' sync'
	endfor
endfunction
"}}}

let s:kind_clients.action_table.a_p4_client_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'クライアントの情報 ( info ) ',
			\ }
function! s:kind_clients.action_table.a_p4_client_info.func(candidates) "{{{

	let clients = []
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port
		let client = port.' -c '.clname
		call add(clients, client)
	endfor

	let datas = perforce#cmd#clients(clients, 'info')

	for data in datas
		call perforce#util#log_file(data.client, 0)
		call append(0,datas[0].outs)
		cursor(1, 1)
	endfor
	
endfunction
"}}}

let s:kind_clients.action_table.a_p4_client = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'クライアントの情報 ( client )',
			\ }
function! s:kind_clients.action_table.a_p4_client.func(candidates) "{{{

	let datas = []
	for l:candidate in a:candidates
		let clname = l:candidate.action__clname
		let port   = l:candidate.action__port
		let client = port.' -c '.clname

		let tmps = perforce#cmd#clients([client], 'p4 client -o '.clname)
		call extend(datas, tmps)
	endfor

	for data in datas
		call perforce#util#log_file(data.client, 0)
		call append(0,data.outs)
		call cursor(28, 1)
	endfor

endfunction
"}}}

call unite#define_kind(s:kind_clients)

let &cpo = s:save_cpo
unlet s:save_cpo

