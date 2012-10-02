function! unite#sources#p4_clients#define()
	return s:source_p4_clients
endfunction


let s:source = {
			\ 'name' : 'p4_clients',
			\ 'description' : 'クライアントの表示',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	return s:get_pfclients()
endfunction "}}}
let s:source_p4_clients = s:source

" ================================================================================
" SubRoutine
" ================================================================================
function! s:get_pfclients() "{{{
	" ********************************************************************************
	" クライアントを表示する
	" ********************************************************************************

	"ポートのクライアントを表示する
	let datas = []
	let ports = perforce#data#get('ports', 'common')
	for port in ports
		let datas += map(perforce#pfcmds('clients','-p '.port), "{
					\ 'port' : port,
					\ 'client' : v:val,
					\ }")
	endfor

	let candidates = map(datas, "{
				\ 'word' : '-p '.v:val.port.' -c '.perforce#get_ClientName_from_client(v:val.client),
				\ 'kind' : 'k_p4_clients',
				\ 'action__clname' : perforce#get_ClientName_from_client(v:val.client),
				\ 'action__port' : v:val.port,
				\ }")
	return candidates
endfunction "}}}
