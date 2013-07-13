let s:save_cpo = &cpo
set cpo&vim

let s:cache_client = {}
let s:cache_client_root = {}
function! s:get_outs_from_clients(port) "{{{

	let port = a:port=='' ? ' ' : a:port

	let outs = []
	for user in perforce#data#get_users()
		let cmd = 'p4 '.port.' clients '
		call extend(outs, split(perforce#system(cmd), "\n"))
	endfor

	return outs
endfunction
"}}}
function! s:get_port_client_roots(port, root) "{{{

	let port = a:port=='' ? ' ' : a:port

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
			let root   = matchstr(out, 'Client \w\+ ....\/..\/.. root \zs.\{-}\ze ''')

			let s:cache_client[port][port. ' -c '.client] = root
		endfor
	endif
	"}}}

	" 検索
	for port_client in keys(s:cache_client[port])
		let root = s:cache_client[port][port_client]
		if a:root =~ escape(root, '\\')
			call add(s:cache_client_root[port][a:root], port_client)
		endif
	endfor

	" 戻り値
	if exists('s:cache_client_root[port][a:root]')
		let rtn = s:cache_client_root[port][a:root]
	else
		let rtn = ''
	endif

	return rtn

endfunction
"}}}


if exists('s:cache_ports')
	unlet s:cache_ports
endif
function! s:get_all_port() "{{{
	if !exists('s:cache_ports')
		let ports = perforce#data#get_orig('g:unite_perforce_ports_clients').items
		
		call add(ports, perforce#get#cache_port())


		call filter(ports, 'v:val =~ "-p"')
		call map(ports, '"-p ".matchstr(v:val, ''-p\s*\zs\S*'')')
		let uniq_port = {}
		for port in ports
			let uniq_port[port] = ''
		endfor
		let s:cache_ports = keys(uniq_port)
	endif
	return s:cache_ports
endfunction
" }}}
function! perforce#get#auto_client#main() "{{{
	let cd = expand("%:p:h")
	let clients = []
	let ports = s:get_all_port()
	for port in ports
		let tmp = s:get_port_client_roots(port, cd)
		call extend(clients, tmp)
	endfor

	if len(clients) == 0
		echo 'use default...'
		let clients = [perforce#get#cache_client()]
	endif

	return clients
endfunction
"}}}
"
command! DebugPfData call s:debug()
function! s:debug() "{{{
	if exists("g:debug")
		unlet g:debug
	endif
	let g:debug = [
				\ s:cache_ports,
				\ s:cache_client_root,
				\ ]
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
