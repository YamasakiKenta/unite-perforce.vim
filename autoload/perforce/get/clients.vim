let s:save_cpo = &cpo
set cpo&vim

" 引数で指定したい場合
function! s:get_default_client()
		return [perforce#get#cache_client()]
endfunction

function! perforce#get#clients#get_ports(...) "{{{
	if a:0 == 0
		let datas = s:get_unite_perforce_ports_clients()
	else
		let datas = a:000
	endif
	return s:get_ports_from_arg(datas)
endfunction
"}}}
function! perforce#get#clients#get_clients(...) "{{{

	let mode_ = perforce#data#get('g:unite_perforce_clients')

	if mode_ == 'default'
		let clients = s:get_default_client()
	elseif mode_ == 'port_clients'
		if a:0 == 0
			let clients = s:get_unite_perforce_ports_clients()
		else
			let clients = a:000
		endif
		let clients = s:get_clients_from_arg(clients)
	else 
		let clients = ['']
	endif

	return  clients
endfunction
"}}}
function! perforce#get#clients#get_port_clients() "{{{
	let clients = s:get_unite_perforce_ports_clients()
	if len(clients) == 0
		let clients = [perforce#get#cache_port_client()]
	endif
	return clients
endfunction
"}}}

" 表示で使用したい場合
function! perforce#get#clients#get_use_ports(...) "{{{
	return call('perforce#get#clients#get_ports', a:000)
endfunction
"}}}
function! s:get_use_clients(...) "{{{
	let mode_ = perforce#data#get('g:unite_perforce_clients')

	if mode_ == 'none'
		let clients = s:get_default_client()
	else
		let clients = call('perforce#get#clients#get_clients', a:000)
	endif

	return clients
endfunction
"}}}
function! perforce#get#clients#get_use_port_clients(...) "{{{

	let ports   = call('perforce#get#clients#get_use_ports',   a:000)
	let clients = call('s:get_use_clients',             a:000)

	let port_clients = []
	for port in ports
		for client in clients
			let port_client = port.' '.client
			call add(port_clients, port_client)
		endfor
	endfor

	if len(port_clients) == 0
		let port_clients = [perforce#get#cache_port_client()]
	endif

	return port_clients

endfunction
"}}}

" -p, -c をつける
function! s:get_ports_from_arg(datas) "{{{
	let datas = a:datas

	let ports = []
	for data in datas
		let port = matchstr(data, '-p\s\+\zs\S*')
		if len(port)
			call add(ports, port)
		endif
	endfor

	if len(ports) == 0 
		let port = '-p '.perforce#get#PFPORT()
		let ports = [port]
	else
		call map(ports, "' -p '.v:val.' '")
	endif

	return ports
endfunction
"}}}
function! s:get_clients_from_arg(datas) "{{{
	let datas = a:datas

	let clients = []
	for data in datas
		let client = matchstr(data, '-c\s\+\zs\S*')
		if len(client)
			call add(clients, client)
		endif
	endfor

	if len(clients) == 0 
		let clients = [perforce#get#cache_client()]
	else
		call map(clients, "' -c '.v:val.' '")
	endif

	return clients
endfunction
"}}}

function! s:get_unite_perforce_ports_clients() "{{{
	let datas = perforce#data#get('g:unite_perforce_ports_clients')

	let num = index(datas, 'auto')
	if num != -1
		unlet datas[num]
		let tmp_clients = perforce#get#auto_client#main()

		let tmp_dir = {}
		for tmp_client in tmp_clients + datas
			let tmp_dir[tmp_client] = ''
		endfor
		let datas = keys(tmp_dir)
	endif

	return datas
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
