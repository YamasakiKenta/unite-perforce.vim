let s:save_cpo = &cpo
set cpo&vim

let s:cache_client = {}
let s:cache_client_root = {}
function! s:get_outs_from_clients(port) "{{{

	if !len(a:port)
		return []
	endif

	let port = a:port

	let outs = []
	for user in perforce#data#get_users()
		let cmd = 'p4 '.port.' clients '.user
		call extend(outs, split(perforce#system(cmd), "\n"))
	endfor

	return outs
endfunction
"}}}
function! s:get_port_client_roots(port, root) "{{{

	if !len(a:port)
		return []
	endif

	let port = a:port
	let root = a:root

	" cache から取得
	if exists('s:cache_client_root[port][a:root]')
		return s:cache_client_root[port][a:root]
	endif

	let s:cache_client_root[port] = get(s:cache_client_root, port, {})
	let s:cache_client_root[port][a:root] = []

	" perforce から取得
	if !exists('s:cache_client[port]') "{{{
		let s:cache_client[port] = {}

		" クライアントの取得
		let outs = s:get_outs_from_clients(port)

		" cacheの設定
		for out in outs
			let client = matchstr(out, 'Client \zs\w\+')
			let tmp_root   = matchstr(out, 'Client \w\+ ....\/..\/.. tmp_root \zs.\{-}\ze ''')

			let s:cache_client[port][port. ' -c '.client] = tmp_root
		endfor
	endif
	"}}}

	" 検索
	for port_client in keys(s:cache_client[port])
		let tmp_root = s:cache_client[port][port_client]
		if root =~ escape(tmp_root, '\\')
			call add(s:cache_client_root[port][a:root], port_client)
		endif
	endfor

	" 戻り値
	if exists('s:cache_client_root[port][a:root]')
		let rtn = s:cache_client_root[port][a:root]
	else
		let rtn = []
	endif

	return rtn

endfunction
"}}}

function! s:get_all_port() "{{{
	" そのまま呼ぶと、auto と被る為、先に設定する
	let tmps = perforce#data#get('g:unite_perforce_ports_clients')
	return call('perforce#get#clients#get_ports', tmps)
endfunction
" }}}

let s:cache_file_client = {}
function! s:get_client_from_fname(fname, clients) "{{{
	let fname = a:fname
	if len(fname) == 0
		return []
	endif
	if !exists('s:cache_file_client[fname]')
		let s:cache_file_client[fname] = {}
	endif
	let clients = []
	for client in a:clients
		if !exists('s:cache_file_client[fname][client]')
			let cmd = 'p4 '.client.' fstat "'.fname.'"'
			let outs = split(perforce#system(cmd), "\n")
			let s:cache_file_client[fname][client] = ( len(outs) > 1 )
		endif
		if s:cache_file_client[fname][client] == 1
			call add(clients, client)
		endif
	endfor
	return clients
endfunction
"}}}

function! perforce#get#auto_client#main() "{{{
	let cd = expand("%:p:h")
	let clients = []
	let ports = s:get_all_port()

	for port in ports
		let tmp = s:get_port_client_roots(port, cd)
		call extend(clients, tmp)
	endfor

	let clients = s:get_client_from_fname(expand("%:p"), clients)

	if len(clients) == 0
		echom 'use default...'
		let clients = [perforce#get#cache_client()]
	endif

	return clients
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
