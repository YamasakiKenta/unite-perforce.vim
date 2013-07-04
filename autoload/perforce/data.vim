let s:save_cpo = &cpo
set cpo&vim

function! s:init() "{{{
	if s:have_unite_setting() == 0
		return
	endif

	if exists('s:init_flg')
		return
	else
		let s:init_flg = 1
	endif

	echo "load ..."

	call s:perforce_init()

	call s:perforce_add( 'g:unite_perforce_ports_clients', {'nums' : [0,1], 'items' : ['-p localhost:1819', '-p localhost:2013']}) 
	call s:perforce_add( 'g:unite_perforce_clients'      , {'nums' : [0],   'items' : ['none', 'default', 'port_clients', 'auto'], 'consts' : [-1] })
	call s:perforce_add( 'g:unite_perforce_filters'      , {'nums' : [0,1], 'items' : ['tag', 'snip']})
	call s:perforce_add( 'g:unite_perforce_show_max'     , {'nums' : [0],   'items' : [0, 5, 10],                   'consts' : [0]})
	call s:perforce_add( 'g:unite_perforce_diff_tool'    , {'nums' : [0],   'items' : ['vimdiff', 'WinMergeU'],     'consts' : [0]}) 
	call s:perforce_add( 'g:unite_perforce_username'     , {'nums' : [0,1], 'items' : ['user']}) 
	call s:perforce_add( 'g:unite_perforce_is_submit_flg', 0) 
	call s:perforce_add( 'g:pf_clients_template'         , {}) 
	call s:perforce_add( 'g:pf_var'                      , '') 
	call s:perforce_add( 'g:perforce_merge_default_path' , {'nums' : [0], 'items' : ['c:\tmp']})

	call s:perforce_load()

	echo 'end...'

endfunction
"}}}

function! s:have_unite_setting() "{{{
	try
		call unite_setting_ex#version()
		return 1
	catch
		echo 'not have unite_setting.vim...'
		return 0
	endtry
endfunction
"}}}

function! s:perforce_add(...) 
	return call('unite_setting_ex#data#add', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_init(...) 
	return call('unite_setting_ex#data#init', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_load(...) 
	return call('unite_setting_ex#data#load', extend(['g:unite_pf_data'] , a:000))
endfunction

function! perforce#data#get(valname, ...) "{{{
	if s:have_unite_setting() == 0
		exe 'let tmp = '.a:valname
		return tmp
	endif

	call s:init()
	return unite_setting_ex#data#get('g:unite_pf_data', a:valname)
endfunction
"}}}
function! perforce#data#setting()  "{{{
	if s:have_unite_setting() == 0
		return
	endif

	call s:init()
	call unite#start([['settings_ex', 'g:unite_pf_data']])
endfunction
"}}}
function! perforce#data#get_users() "{{{
	let users = perforce#data#get('g:unite_perforce_username')

	call map(users, "' -u '.v:val.' '")

	if len(users) == 0
		"let user = perforce#get#PFUSER()
		"let users = [user]
		let users = ['']
	endif

	return users
endfunction
"}}}
function! perforce#data#get_max() "{{{
	let max = perforce#data#get('g:unite_perforce_show_max')

	if max > 0 
		let max = '-m '.max.' '
	else
		let max = ''
	endif

	return max
endfunction
"}}}
" 引数でしていしたい場合
function! s:get_client_defoult()
		return [perforce#get#cache_client()]
endfunction

let s:cache_client = {}
let s:cache_client_root = {}
function! s:get_outs_from_clients(port) "{{{
	if len(a:port) == 0
		let port = ' '
	else
		let port = a:port
	endif

	let outs = []
	for user in perforce#data#get_users()
		let cmd = 'p4 '.port.' clients '
		call extend(outs, split(system(cmd), "\n"))
	endfor

	return outs
endfunction
"}}}
function! s:get_port_client_roots(port, root) "{{{

	let port = a:port=='' ? ' ' : a:port
	
	" cache から取得
	if exists('s:cache_client_root[port][a:root]')
		return s:cache_client_root[port][a:root]
	else
		if !exists('s:cache_client_root[port]')
			let s:cache_client_root[port] = {}
		endif
		let s:cache_client_root[port][a:root] = []
	endif

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
	for port_client in keys(s:cache_client[port]) "{{{
		let root = s:cache_client[port][port_client]
		if a:root =~ escape(root, '\\')
			call add(s:cache_client_root[port][a:root], port_client)
		endif
	endfor
	"}}}

	" 戻り値
	if exists('s:cache_client_root[port][a:root]')
		let rtn = s:cache_client_root[port][a:root]
	else
		let rtn = ''
	endif

	return rtn

endfunction
"}}}

function! s:get_port_client_auto() "{{{
	let cd = getcwd()
	let ports = perforce#data#get_use_ports()
	let clients = []
	for port in ports
		let tmp = s:get_port_client_roots(port, cd)
		call extend(clients, tmp)
	endfor

	if len(clients) == 0
		let clients = perforce#data#get_port_clients()
	endif
	return clients
endfunction
"}}}

function! perforce#data#get_ports(...) "{{{
	if a:0 == 0
		let datas = perforce#data#get('g:unite_perforce_ports_clients')
	else
		let datas = a:000
	endif
	return s:get_ports_from_arg(datas)
endfunction
"}}}
function! perforce#data#get_clients(...) "{{{

	let mode_ = perforce#data#get('g:unite_perforce_clients')

	if mode_ == 'default'
		let clients = s:get_client_defoult()
	elseif mode_ == 'auto'
		let clients = s:get_port_client_auto()
	elseif mode_ == 'port_clients'
		if a:0 == 0
			let clients = perforce#data#get('g:unite_perforce_ports_clients')
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
function! perforce#data#get_port_clients() "{{{
	let clients = perforce#data#get('g:unite_perforce_ports_clients')
	if len(clients) == 0
		let clients = [perforce#get#cache_port_client()]
	endif
	return clients
endfunction
"}}}
" 表示で使用したい場合
function! perforce#data#get_use_ports(...) "{{{
	return call('perforce#data#get_ports', a:000)
endfunction
"}}}
function! s:get_use_clients(...) "{{{
	let mode_ = perforce#data#get('g:unite_perforce_clients')

	if mode_ == 'none'
		let clients = s:get_client_defoult()
	else
		let clients = call('perforce#data#get_clients', a:000)
	endif

	return clients
endfunction
"}}}
function! perforce#data#get_use_port_clients(...) "{{{

	let ports   = call('perforce#data#get_use_ports',   a:000)
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

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
endif
