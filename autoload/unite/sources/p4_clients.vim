let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_clients#define()
	return s:source_p4_clients
endfunction

function! s:get_client_name_from_clients(str) 
	return matchstr(a:str,'Client \zs\S\+')
endfunction

let s:source_p4_clients = {
			\ 'name'         : 'p4_clients',
			\ 'description'  : 'クライアントの表示',
			\ 'default_kind' : 'k_p4_clients',
			\ }
function! s:source_p4_clients.gather_candidates(args, context) 
	" ********************************************************************************
	" クライアントを表示する
	" ********************************************************************************

	let use_ports = perforce#get#clients#get_use_ports()

	let max    = perforce#data#get_max()
	let users = perforce#data#get_users()
	let candidates = []
	for port in use_ports 
		for user in users
			let tmp_datas = perforce#system_dict(port, 'p4 '.port.' clients '.user.' '.max)
			for data in tmp_datas
				call add(candidates, {
							\ 'word'           : '-h '.data.Host.' '.data.port.' -c '.data.client,
							\ 'action__clname' : data.client,
							\ 'action__port'   : data.port,
							\ })
			endfor
		endfor
	endfor

	return candidates
endfunction 

if 1
	call unite#define_source(s:source_p4_clients)
endif


let &cpo = s:save_cpo
unlet s:save_cpo

