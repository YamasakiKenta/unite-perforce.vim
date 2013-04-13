let s:save_cpo = &cpo
set cpo&vim

function! s:pfcmds_port_only(cmd, head, tail) "{{{
	" ********************************************************************************
	" @par       設定のクライアントから、ポートのみ取得する
	" ********************************************************************************
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:cmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT().'-c '.perforce#get#PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data_port_only(a:cmd, a:head, a:tail)
	endif

	return rtns
endfunction
"}}}
"

function! s:pfcmds_with_clients_and_unite_mes(clients, cmd, head, tail) "{{{
	let rtns = s:pfcmds_with_clients(a:clients, a:cmd, a:head, a:tail)

	for cmd in map(deepcopy(rtns), "v:val.cmd")
		call unite#print_message('[cmd] '.cmd)
	endfor

	return rtns
endfunction
"}}}
function! s:pfcmds_new_get_outs(datas) "{{{
	let outs = []
	for data in a:datas
		call extend(outs, get(data, 'outs', []))
	endfor
	return outs
endfunction
"}}}
function! s:pfcmds_with_clients_from_data(pfcmd,head,tail) "{{{
	let clients = perforce#data#get('clients')
	return  s:pfcmds_with_clients_and_unite_mes(clients, a:pfcmd, a:head, a:tail)
endfunction
"}}}

function! perforce#cmd#new_outs(pfcmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:pfcmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT().' -c '.perforce#get#PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data(a:pfcmd, a:head, a:tail)
	endif

	let rtns = s:pfcmds_new_get_outs(rtns)

	return rtns
endfunction
"}}}
function! perforce#cmd#new(pfcmd, head, tail) "{{{
	let client_default_flg = perforce#data#get('use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:pfcmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT().' -c '.perforce#get#PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data(a:pfcmd, a:head, a:tail)
	endif

	return rtns
endfunction
"}}}

function! perforce#cmd#base(pfcmd,...) "{{{
	" ********************************************************************************
	" p4 コマンドを実行します
	" @param[in]	str		pfcmd		コマンド
	" @param[in]	str		head	コマンドの前に挿入する
	" @param[in]	str		a:000	コマンドの後に挿入する
	" ********************************************************************************

	let gcmds = ['p4']
	if a:0 > 0 
		call add(gcmds, a:1)
	endif

	call add(gcmds, a:pfcmd)

	if a:pfcmd =~ 'changes'
		if perforce#data#get('client_changes_only') == 1
			call add(gcmds, '-c '.perforce#get#PFCLIENTNAME())
		endif
	endif 

	if a:pfcmd =~ 'clients' || a:pfcmd =~ 'changes'
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
	let rtn_d.outs = s:conv_error(rtn_d.outs)

	call unite#print_message(rtn_d.cmd)

	" 非表示にするコマンド
	if perforce#data#get('filters_flg') == 1
		let filter_ = join(perforce#data#get('filters'), '\|' ) 
		call filter(rtn_d.outs, 'v:val !~ filter_')
	endif

	return rtn_d
endfunction
"}}}
" ----
"  NEW
function! s:conv_error(outs) "{{{
	let outs = a:outs
	if len(outs) > 0
		if outs[0] =~ "^Perforce client error:"
			let outs = ['ERROR']
		endif
	else
		let outs = ['ERROR']
	endif
	return outs
endfunction
"}}}
function! s:get_outs(cmd) "{{{
	" @par filter を除いた値を返します
	let kind = '__common'
	let outs = split(system(a:cmd),'\n')

	if perforce#data#get('filters_flg',kind) == 1
		let filter_ = join( perforce#data#get('filters',kind), '\|' ) 
		call filter(outs, 'v:val !~ filter_')
	endif

	let outs = s:conv_error(outs)

	return outs
endfunction
"}}}
function! s:get_foot(pfcmd, foot_d) "{{{
	" コマンド毎に使用する 引数を取得する
	"
	let max     = get(a:foot_d, 'max',    '')
	let user    = get(a:foot_d, 'user',   '')
	let client  = get(a:foot_d, 'client', '')

	let foots = [max]
	if a:pfcmd == 'clients'
		call add(foots, user)
	elseif a:pfcmd == 'changes'
		call add(foots, user)
		call add(foots, client)
	endif 

	return join(foots)
endfunction
"}}}
function! s:pfcmds_with_client(pfcmd, client, foot_d) "{{{
	let foot = s:get_foot(a:pfcmd, a:foot_d)
	let cmd  = 'p4 '.a:client.' '.a:pfcmd.' '.foot
	return  {
				\ 'cmd'    : cmd,
				\ 'client' : a:client,
				\ 'outs'   : s:get_outs(cmd),
				\ }
endfunction
"}}}
function! s:pfcmds_with_clients(clients, pfcmd, head, tail) "{{{

	let kind = '__common'
	let foot_d = {}

	if perforce#data#get('show_max_flg', kind) == 1
		foot_d.max = '-m '.perforce#data#get('show_max', kind)
	else 
	endif 

	if perforce#data#get('user_changes_only',kind) == 1 
		let foot_d.user = '-u '.perforce#get#PFUSER()
	endif

	let rtns = []
	if perforce#data#get('client_changes_only',kind) == 1
		" echo a:clients " DEBUG
		" call input("") " DEBUG
		for client in a:clients
		 	let foot_d.client = '-c '.client " 差分
			call add(rtns, s:pfcmds_with_client(a:pfcmd, client, foot_d))
		endfor 
	else
		for client in a:clients
			call add(rtns, s:pfcmds_with_client(a:pfcmd, client, foot_d))
		endfor 
	endif

	return rtns
endfunction
"}}}
function! s:pfcmds_with_clients_from_data_port_only(pfcmd,head,tail) "{{{
	let clients = perforce#data#get('clients')
	let port_d  = {}
	for client in clients
		let port = matchstr(client, '-p\s*\S*')
		let port_d[port] = ''
	endfor

	let datas = s:pfcmds_with_clients_and_unite_mes(keys(port_d), a:pfcmd, a:head, a:tail)
	return  datas
endfunction
"}}}

" ----
" new I/F
function! perforce#cmd#main(pfcmd)
	if a:pfcmd == 'clients'
		return s:pfcmds_port_only('clients', '', '')
	endif
endfunction

function! perforce#cmd#files(pfcmd, files)
	" ********************************************************************************
	" @par       
	" @param[out]  datas = [ 'cmd' : '', 'outs' ]
	" @retval    
	" ********************************************************************************
	"
	if a:pfcmd == 'diff'
		if perforce#data#get('diff -dw', 'common') == 1
		endif
	endif

	return datas
endfunction


function! perforce#cmd#clients(pfcmd, clints)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

