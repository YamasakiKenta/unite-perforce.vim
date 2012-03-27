function! unite#sources#p4_clients#define()
	return [s:source_p4_clients , s:source_p4_all_clients]
endfunction

function! s:get_pfclients(str) "{{{

	"ポートのクライアントを表示する
	let datas = []
	for port in g:pf_ports
		let datas += map(perforce#cmds('-P '.port.' clients '.a:str),"[port , v:val]")
	endfor

	let candidates = map(datas, "{
				\ 'word' : v:val[0].':'.perforce#get_ClientName_from_client(v:val[1]),
				\ 'kind' : 'k_p4_clients',
				\ 'action__clname' : perforce#get_ClientName_from_client(v:val[1]),
				\ 'action__port' : v:val[0],
				\ }")
	return candidates
endfunction "}}}

let s:source = {
			\ 'name' : 'p4_clients',
			\ 'default_action' : 'a_p4_client_set',
			\ 'description' : 'クライアントの表示',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	return <SID>get_pfclients(perforce#get_PFUSER_for_pfcmd()) 
endfunction "}}}
let s:source_p4_clients = s:source
unlet s:source

let s:source = {
			\ 'name' : 'p4_all_clients',
			\ 'default_action' : 'a_p4_client_info',
			\ 'description' : '全てのクライアントの表示',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	return <SID>get_pfclients(" ")
endfunction "}}}
let s:source_p4_all_clients = s:source
unlet s:source
