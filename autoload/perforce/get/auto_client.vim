let s:save_cpo = &cpo
set cpo&vim

let s:cache_client = {}
let s:cache_client_root = {}
function! s:get_outs_from_clients(port) "{{{

	if !len(a:port)
		return []
	endif

	if 0

		let outs = []
		let max = perforce#data#get_max()
		for user in perforce#data#get_users()
			let cmd = 'p4 '.a:port.' clients '.user.' '.max
			call extend(outs, split(perforce#system(cmd), "\n"))
		endfor

		return outs
	else
		let rtns = []
		let max = perforce#data#get_max()
		let port = a:port
		let port = substitute(port, '-p', '', '')
		let port = substitute(port, ' ', '', 'g')
		for user in perforce#data#get_users()
			let cmd = 'p4 '.a:port.' clients '.user.' '.max
			call extend(rtns, perforce#system_dict(port, cmd))
		endfor

		return rtns
	endif
endfunction
"}}}
function! s:set_cache_port_root_init(port, root) "{{{
	let s:cache_client_root[a:port] = get(s:cache_client_root, a:port, {})
	let s:cache_client_root[a:port][a:root] = []
endfunction
"}}}
function! s:get_port_client_from_roots(port, root) "{{{

	if !len(a:port)
		return []
	endif

	" cache から取得
	if exists('s:cache_client_root[a:port][a:root]')
		return s:cache_client_root[a:port][a:root]
	endif

	" cache の初期化
	call s:set_cache_port_root_init(a:port, a:root)

	let port = a:port
	let root = a:root

	" perforce から取得
	if !exists('s:cache_client[port]') "{{{
		let s:cache_client[port] = {}

		" クライアントの取得
		let outs = s:get_outs_from_clients(port)

		" cacheの設定
		for out in outs
			let client   = out.client
			let tmp_root = out.Root
			let s:cache_client[port][client] = tmp_root
		endfor
	endif
	"}}}

	" 検索
	for client in keys(s:cache_client[port])
		let tmp_root = s:cache_client[port][client]
		if len(tmp_root) > 0 && root =~ escape(tmp_root, '\\') 
			call add(s:cache_client_root[port][a:root], client)
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

function! perforce#get#auto_client#main() "{{{
	let cd = expand("%:p:h")
	let clients = []
	let ports = perforce#get#clients#get_ports()

	for port in ports
		let tmp = s:get_port_client_from_roots(port, cd)
		call extend(clients, map(tmp, 'port." -c ".v:val'))
	endfor

	" file 所持の確認は時間かがかかる為、保留
	if len(clients) == 0
		echom 'use default...'
		let clients = [perforce#get#cache_client()]
	endif

	echo clients
	call input("")

	return clients
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
