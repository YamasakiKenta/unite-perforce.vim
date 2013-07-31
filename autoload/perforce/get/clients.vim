let s:save_cpo = &cpo
set cpo&vim

" 引数が指定されている場合は、引数のクライアントを使用する
" ない場合は、設定しているクライアントを取得する
" global option
function! perforce#get#clients#get_ports(...) "{{{
	if a:0 == 0
		let datas = perforce#data#get('g:unite_perforce_ports')
		call map(datas, '"-p ".v:val')
		return datas
	else
		return s:get_petern_from_arg('-p', a:000)
	endif
endfunction
"}}}
function! perforce#get#clients#get_args_clients(...) "{{{

	let mode_ = perforce#data#get('g:unite_perforce_args_clients')

	if mode_ == 'default'
		let clients = [perforce#get#cache_client()]
	elseif mode_ == 'port_clients'
		if a:0 == 0
			let clients = s:get_unite_perforce_ports_clients()
		else
			let clients = a:000
		endif

		let clients = s:get_petern_from_arg('-c', clients)
	else 
		let clients = ['']
	endif

	return  clients
endfunction
"}}}
function! perforce#get#clients#get_clients(...) "{{{

	if a:0 == 0
		let clients = s:get_unite_perforce_ports_clients()
	else
		let clients = a:000
	endif

	let clients = s:get_petern_from_arg('-c', clients)

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

" normal option
function! s:get_use_clients(...) "{{{
	let mode_ = perforce#data#get('g:unite_perforce_args_clients')

	if mode_ == 'none'
		let clients = [perforce#get#cache_client()]
	else
		let clients = call('perforce#get#clients#get_clients', a:000)
	endif

	return clients
endfunction
"}}}
function! perforce#get#clients#get_use_ports(...) "{{{
	return call('perforce#get#clients#get_ports', a:000)
endfunction
"}}}
function! perforce#get#clients#get_use_port_clients(...) "{{{

	let ports   = call('perforce#get#clients#get_use_ports' , a:000)
	let clients = call('s:get_use_clients'                  , a:000)

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

function! s:uniq(datas)
	return filter(a:datas, 'count(a:datas[0: v:key], v:val) == 1')
endfunction

" -p, -c をつける
function! s:get_petern_from_arg(ptrn, datas) "{{{
	let rtn_datas = copy(a:datas)
	call map(rtn_datas, 'matchstr(v:val, '''.a:ptrn.'\s\+\zs\S*'')')
	call filter(rtn_datas, 'len(v:val)')
	call s:uniq(rtn_datas)

	call map(rtn_datas, "' '.a:ptrn.' '.v:val.' '")

	return rtn_datas
endfunction
"}}}
function! s:get_unite_perforce_ports_clients() "{{{
	let ports = perforce#data#get('g:unite_perforce_ports')
	let clients = perforce#data#get('g:unite_perforce_clients')

	let cache_index = index(clients, 'auto')
	if cache_index != -1
		unlet clients(cache_index)
		call extend(clients, perforce#get#auto_client#main())
	endif

	for port in ports
		for client in clients
			let servers = ' -p '.port.' -c '.client
		endfor
	endfor

	return servers
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
