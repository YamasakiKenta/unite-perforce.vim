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
	let max = perforce#data#get_max()
	for user in perforce#data#get_users()
		let cmd = 'p4 '.port.' clients '.user.' '.max
		call extend(outs, split(perforce#system(cmd), "\n"))
	endfor

	return outs
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

	" cache ����擾
	if exists('s:cache_client_root[a:port][a:root]')
		return s:cache_client_root[a:port][a:root]
	endif

	" cache �̏�����
	call s:set_cache_port_root_init(a:port, a:root)

	let port = a:port
	let root = a:root

	" perforce ����擾
	if !exists('s:cache_client[port]') "{{{
		let s:cache_client[port] = {}

		" �N���C�A���g�̎擾
		let outs = s:get_outs_from_clients(port)

		" cache�̐ݒ�
		for out in outs
			let client = matchstr(out, 'Client \zs\w\+')
			let tmp_root   = matchstr(out, 'Client \w\+ ....\/..\/.. tmp_root \zs.\{-}\ze ''')

			let s:cache_client[port][port. ' -c '.client] = tmp_root
		endfor
	endif
	"}}}

	" ����
	for port_client in keys(s:cache_client[port])
		let tmp_root = s:cache_client[port][port_client]
		if root =~ escape(tmp_root, '\\')
			call add(s:cache_client_root[port][a:root], port_client)
		endif
	endfor

	" �߂�l
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
		call extend(clients, tmp)
	endfor

	" file �����̊m�F�͎��Ԃ���������ׁA�ۗ�
	if len(clients) == 0
		echom 'use default...'
		let clients = [perforce#get#cache_client()]
	endif

	call vimconsole#log(clients)

	return clients
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif