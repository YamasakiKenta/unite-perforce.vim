let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8


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
" SubRoutioe
" ================================================================================
function! s:get_pfclients() "{{{
	" ********************************************************************************
	" クライアントを表示する
	" ********************************************************************************

	let datas = perforce#pfcmds_new_port_only('clients', '', '')

	let candidates = []
	for data in datas
		let port = data.client
		call extend(candidates, map(deepcopy(data['outs']), "{
					\ 'word' : port.' -c '.perforce#get_ClientName_from_client(v:val),
					\ 'kind' : 'k_p4_clients',
					\ 'action__clname' : perforce#get_ClientName_from_client(v:val),
					\ 'action__port' : port,
					\ }"))
	endfor

	return candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

