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
	let file_ = expand('~/.vim-unite-perforce')

	call s:perforce_init(file_)

	call s:perforce_add( 'g:unite_perforce_ports_clients'       ,''                       , {'nums' : [0,1], 'items' : ['-p localhost:1819', '-p localhost:2013']}) 
	call s:perforce_add( 'g:unite_perforce_clients'             ,''                       , {'num'  : 0,     'items' : ['none', 'default', 'port_clients'], 'consts':[-1]})
	call s:perforce_add( 'g:unite_perforce_diff_dw'             ,'空白を無視する'         , 1)
	call s:perforce_add( 'g:unite_perforce_filters'             ,'除外リスト'             , {'nums' : [],    'items' : ['tag', 'snip']})
	call s:perforce_add( 'g:unite_perforce_show_max'            ,'ファイル数の制限'       , {'num'  : 0,     'items' : [0, 5, 10],                   'consts' : [0]})
	call s:perforce_add( 'g:unite_perforce_diff_tool'           ,'Diff で使用するツール'  , {'num'  : 0,     'items' : ['vimdiff', 'WinMergeU'],     'consts' : [0]}) 
	call s:perforce_add( 'g:unite_perforce_username'            ,''                       , {'nums' : [],    'items' : ['user']}) 
	call s:perforce_add( 'g:unite_perforce_is_submit_flg'       ,'サブミットを許可'       , 0) 
	call s:perforce_add( 'g:pf_clients_template'                ,'template'               , {}) 

	call s:perforce_load()

	echo 'end...'

endfunction
"}}}

function! s:have_unite_setting() "{{{
	try
		call unite_setting#have()
		return 1
	catch
		echo 'not have unite_setting.vim...'
		return 0
	endtry
endfunction
"}}}

function! s:perforce_add(...) 
	return call('unite_setting_ex_3#add', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_init(...) 
	return call('unite_setting_ex_3#init', extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_load(...) 
	return call('unite_setting_ex_3#load', extend(['g:unite_pf_data'] , a:000))
endfunction

function! perforce#data#get(valname, ...) "{{{
	if s:have_unite_setting() == 0
		exe 'let tmp = '.a:valname
		return tmp
	endif

	call s:init()
	return unite_setting_ex_3#get('g:unite_pf_data', a:valname)
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
		let max = '-m '.max
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
		echo clients
		let clients = [perforce#get#cache_port_client()]
	endif
	return clients
endfunction
"}}}
" 表示で使用したい場合
function! s:get_use_ports(...) "{{{
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

	let ports   = call('s:get_use_ports',   a:000)
	let clients = call('s:get_use_clients', a:000)

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
