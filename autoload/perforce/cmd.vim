let s:save_cpo = &cpo
set cpo&vim

function! s:pfcmds_with_clients(clients, cmd, head, tail) "{{{

	let kind = '__common'

	if perforce#data#get('show_max_flg', kind) == 1
		let max = '-m '.perforce#data#get('show_max', kind)
	else 
		let max = ''
	endif 

	if perforce#data#get('user_changes_only',kind) == 1 
		let user = '-u '.perforce#get#PFUSER()
	else 
		let user = ''
	endif

	let rtns = []

	for client in a:clients

		let gcmds = ['p4']
		call add(gcmds, a:head)
		call add(gcmds, client)

		call add(gcmds, a:cmd)
		call add(gcmds, max)

		if a:cmd =~ 'clients' || a:cmd =~ 'changes'
			call add(gcmds, user)

		endif 

		if a:cmd =~ 'changes'
			if perforce#data#get('client_changes_only',kind) == 1
				call add(gcmds, '-c '.a:client)
			endif
		endif 

		call add(gcmds, a:tail)

		let cmd = join(gcmds)

		call add(rtns, {
					\ 'cmd'    : cmd,
					\ 'outs'   : split(system(cmd),'\n'),
					\ 'client' : client,
					\ })

		if perforce#data#get('filters_flg',kind) == 1
			let filter_ = join( perforce#data#get('filters',kind), '\|' ) 
			call filter(rtns[-1].outs, 'v:val !~ filter_')
		endif
	endfor 

	return rtns
endfunction "}}}
function! s:pfcmds_new_get_outs(datas) "{{{
	let outs = []
	for data in a:datas
		call extend(outs, get(data, 'outs', []))
	endfor
	return outs
endfunction
"}}}
function! s:pfcmds_with_clients_from_data(cmd,head,tail) "{{{
	let clients = perforce#data#get('clients')
	return  s:pfcmds_with_clients_and_unite_mes(clients, a:cmd, a:head, a:tail)
endfunction "}}}
function! s:pfcmds_with_clients_and_unite_mes(clients, cmd, head, tail) "{{{
	let rtns = s:pfcmds_with_clients(a:clients, a:cmd, a:head, a:tail)

	for cmd in map(deepcopy(rtns), "v:val.cmd")
		call unite#print_message('[cmd] '.cmd)
	endfor

	return rtns
endfunction "}}}
function! s:pfcmds_with_clients_from_data_port_only(cmd,head,tail) "{{{
	let clients = perforce#data#get('clients')
	let ports = []
	for client in clients
		let port = matchstr(client, '-p\s*\S*')
		if len(port)
			call add(ports, port)
		endif
	endfor
	return  s:pfcmds_with_clients_and_unite_mes(ports, a:cmd, a:head, a:tail)
endfunction "}}}

function! perforce#cmd#new_port_only(cmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data_port_only(a:cmd, a:head, a:tail)
	endif

	return rtns
endfunction "}}}
function! perforce#cmd#new_outs(cmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT().' -c '.perforce#get#PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data(a:cmd, a:head, a:tail)
	endif

	let rtns = s:pfcmds_new_get_outs(rtns)

	return rtns
endfunction "}}}
function! perforce#cmd#new(cmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT().' -c '.perforce#get#PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data(a:cmd, a:head, a:tail)
	endif

	return rtns
endfunction "}}}

function! perforce#cmd#base(cmd,...) "{{{
	" ********************************************************************************
	" p4 コマンドを実行します
	" @param[in]	str		cmd		コマンド
	" @param[in]	str		head	コマンドの前に挿入する
	" @param[in]	str		a:000	コマンドの後に挿入する
	" ********************************************************************************

	let gcmds = ['p4']
	if a:0 > 0 
		call add(gcmds, a:1)
	endif

	call add(gcmds, a:cmd)

	if a:cmd =~ 'changes'
		if perforce#data#get('client_changes_only') == 1
			call add(gcmds, '-c '.perforce#get#PFCLIENTNAME())
		endif
	endif 

	if a:cmd =~ 'clients' || a:cmd =~ 'changes'
		if perforce#data#get('user_changes_only') == 1 
			call add(gcmds, '-u '.perforce#get#PFUSER())
		endif
	endif 


	if perforce#data#get('show_max_flg') == 1
		call add(gcmds, '-m '.perforce#data#get('show_max'))
	endif 


	if a:0 > 1
		call add(gcmds, join(a:000[1:]))
	endif

	let cmd = join(gcmds)
	let rtn_d = {
				\ 'cmd'  : cmd,
				\ 'outs' : split(system(cmd),'\n'),
				\ }

	" Error
	if len(rtn_d.outs) > 0
		if rtn_d.outs[0] =~ "^Perforce client error:"
			let rtn_d.outs = ['ERROR']
		endif
	else
		let rtn_d.outs = ['ERROR']
	endif

	call unite#print_message(rtn_d.cmd)

	" 非表示にするコマンド
	if perforce#data#get('filters_flg') == 1
		let filter_ = join(perforce#data#get('filters'), '\|' ) 
		call filter(rtn_d.outs, 'v:val !~ filter_')
	endif

	return rtn_d
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

