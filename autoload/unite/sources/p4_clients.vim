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

	let use_ports = perforce#data#get_use_ports()

	let max    = perforce#data#get_max()
	let users = perforce#data#get_users()
	let datas  = []
	for user in users
		call extend(datas, perforce#cmd#clients(use_ports, 'p4 clients '.user.' '.max))
	endfor

	let candidates = []
	for data in datas
		let port = data.client
		if get(data.outs, 0, 'ERROR') == 'ERROR'
			call add(candidates, {
						\ 'word' : port.' - ERROR',
						\ 'kind' : 'common',
						\ })
		else
			call extend(candidates, map(deepcopy(data['outs']), "{
						\ 'word'           : port.' -c '.s:get_client_name_from_clients(v:val),
						\ 'action__clname' : s:get_client_name_from_clients(v:val),
						\ 'action__port'   : port,
						\ }"))
		endif
	endfor

	return candidates
endfunction 

if 1
	call unite#define_source(s:source_p4_clients)
endif


let &cpo = s:save_cpo
unlet s:save_cpo

