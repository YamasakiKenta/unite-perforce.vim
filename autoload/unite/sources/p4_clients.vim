let s:save_cpo = &cpo
set cpo&vim


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
	let ports = perforce#data#get('ports')

	" デフォルトの追加
	if perforce#data#get('use_default') == 0
		for port in ports
			let datas += map(perforce#pfcmds('clients','-p '.port).outs, "{
						\ 'port' : port,
						\ 'client' : v:val,
						\ }")
		endfor
	else
		let datas += map(perforce#pfcmds('clients').outs, "{
					\ 'port' : perforce#get_PFPORT(),
					\ 'client' : v:val,
					\ }")
	endif

	echo datas
	call input("")

	let candidates = map(datas, "{
				\ 'word' : '-p '.v:val.port.' -c '.perforce#get_ClientName_from_client(v:val.client),
				\ 'kind' : 'k_p4_clients',
				\ 'action__clname' : perforce#get_ClientName_from_client(v:val.client),
				\ 'action__port' : v:val.port,
				\ }")
	return candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

