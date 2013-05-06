let s:save_cpo = &cpo
set cpo&vim

function! s:pfcmds_port_only(pfcmd, head, tail) "{{{
	" ********************************************************************************
	" @param[in]     a:pfcmd      = 'opened'
	" @param[in]     a:head       = '' 
	" @param[in]     a:tail       = ''
	"
	" @return       rtns[]
	" .client' = '-p localhost:1818' 
	" .cmd     = 'p4 opened'
	" .outs[]  = ''  - cmd outputs
	" ********************************************************************************
	
	let client_default_flg = 0 " perforce#data#get('g:unite_perforce_use_default')
	if client_default_flg == 1
		let tmp = perforce#cmd#base(a:pfcmd, a:head, a:tail)
		let tmp.client = '-p '.perforce#get#PFPORT().'-c '.perforce#get#PFCLIENTNAME()
		let rtns = [tmp]
	else
		let rtns = s:pfcmds_with_clients_from_data_port_only(a:pfcmd, a:head, a:tail)
	endif

	return rtns
endfunction
"}}}
function! s:pfcmds_with_clients_and_unite_mes(clients, pfcmd, head, tail) "{{{
	" ********************************************************************************
	" @param[in]     a:clients    = []
	" @param[in]     a:pfcmd      = '' 
	" @param[in]     a:head       = '' 
	" @param[in]     a:tail       = ''
	"
	" @return       rtns[]
	" .client' = '-p localhost:1818 -c origin' 
	" .cmd     = 'p4 opened'
	" .outs[]  = ''  - cmd outputs
	" ********************************************************************************
	let rtns = s:pfcmds_with_clients(a:clients, a:pfcmd, a:head, a:tail)

	for cmd in map(deepcopy(rtns), "v:val.cmd")
		call unite#print_message('[cmd] '.cmd)
	endfor

	return rtns
endfunction
"}}}
function! s:pfcmds_with_clients_from_data(pfcmd, head, tail) "{{{
	" ********************************************************************************
	" @param[in]    a:pfcmd = 'opened'
	" @param[in]    a:head  = ''
	" @param[in]    a:tail  = ''
	"
	" @return       rtns[]
	" .client' = '-p localhost:1818 -c origin' 
	" .cmd     = 'p4 opened'
	" .outs[]  = ''  - cmd outputs
	" ********************************************************************************
	let clients = perforce#get#clients()
	return  s:pfcmds_with_clients_and_unite_mes(clients, a:pfcmd, a:head, a:tail)
endfunction
"}}}

function! perforce#cmd#new(pfcmd, head, tail) "{{{
	" ********************************************************************************
	" @param[in]      a:pfcmd = ''
	" @param[in]      a:head  = ''
	" @param[in]      a:tail  = ''
	"
	" @return       rtns[]
	" .client' = '-p localhost:1818 -c origin' 
	" .cmd     = 'p4 opened'
	" .outs[]  = ''  - cmd outputs
	" ********************************************************************************

	let client_default_flg = 0 " perforce#data#get('g:unite_perforce_use_default')
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
	" @param[in]    a:pfcmd = 'opened'
	" @param[in]    a:000
	" [0]  = ''  - head
	" [1:] = ''  - foot
	"
	" @return rtn_d
	" .cmd    = 'p4 opened'
	" .outs[] = ''
	" ********************************************************************************

	let gcmds = ['p4']
	if a:0 > 0 
		call add(gcmds, a:1)
	endif

	call add(gcmds, a:pfcmd)

	if a:pfcmd =~ 'changes'
		if perforce#data#get('g:unite_perforce_client_changes_only') == 1
			call add(gcmds, '-c '.perforce#get#PFCLIENTNAME())
		endif
	endif 

	if a:pfcmd =~ 'clients' || a:pfcmd =~ 'changes'
		if perforce#data#get('g:unite_perforce_user_changes_only') == 1 
			call add(gcmds, '-u '.perforce#get#PFUSER())
		endif
	endif 


	let max_ = perforce#data#get('g:unite_perforce_show_max')
	if max_ > 0
		call add(gcmds, '-m '.max_)
	endif 


	if a:0 > 1
		call add(gcmds, join(a:000[1:]))
	endif

	let cmd = join(gcmds)
	echo 'perforce#cmd#base -> ' cmd
	let rtn_d = {
				\ 'cmd'  : cmd,
				\ 'outs' : split(system(cmd),'\n'),
				\ }

	" Error の場合は、出力を変更する
	let rtn_d.outs = s:conv_error(rtn_d.outs)

	call unite#print_message(rtn_d.cmd)

	" 非表示にするコマンド
	let filters_ = perforce#data#get('g:unite_perforce_filters')
	if len(join(filters_)) > 0
		let filter_ = join(filters_, '\|' ) 
		call filter(rtn_d.outs, 'v:val !~ filter_')
	endif

	return rtn_d
endfunction
"}}}
" ----
"  NEW
" ----
function! s:conv_error(outs) "{{{
	" ********************************************************************************
	" @par           エラー発生時に、簡潔にする
	" @param[in]     a:outs[] = '' - 出力結果
	"
	" @return        outs[]  = 'ERROR'  - エラー時は、ERRORに変更する
	" @return        outs[]  = a:outs[] - 通常時は、そのまま返す
	" ********************************************************************************
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
	" ********************************************************************************
	" @param[in]     a:cmd = 'p4 opened'
	"
	" @return        outs[] = '' - 出力結果
	" ********************************************************************************
	" @par filter を除いた値を返します
	let kind = '__common'
	echo 's:get_outs -> ' a:cmd
	let outs = split(system(a:cmd),'\n')

	let filters_ = perforce#data#get('g:unite_perforce_filters',kind)
	if len(join(filters_)) > 0
		let filter_ = join( filters_, '\|' ) 
		call filter(outs, 'v:val !~ filter_')
	endif

	let outs = s:conv_error(outs)

	return outs
endfunction
"}}}
function! s:get_foot(pfcmd, foot_d) "{{{
	" ********************************************************************************
	" @par  コマンド毎に使用する 引数を取得する
	" @param[in]     a:pfcmd  = 'opened'
	" @param[in]     a:foot_d
	" .max    = '5'
	" .user   = ''
	" .client = ''
	"
	" @return        foot = ''
	" ********************************************************************************
	"
	let max     = get(a:foot_d, 'max',    '')
	let user    = get(a:foot_d, 'user',   '')
	let client  = get(a:foot_d, 'client', '')
	let base    = get(a:foot_d, 'base', '')

	let foots = []
	call add(foots, max)
	if a:pfcmd == 'clients'
		call add(foots, user)
	elseif a:pfcmd == 'changes'
		call add(foots, user)
		call add(foots, client)
	endif 

	call add(foots, base)

	return join(foots)
endfunction
"}}}
function! s:pfcmds_with_client(pfcmd, client, foot_d) "{{{
	" ********************************************************************************
	" @param[in]      a:pfcmd  = 'opened'
	" @param[in]      a:client = '-p localhost:1818'
	" @param[in]      a:foot_d
	" .max  = ''
	" .user = ''
	"
	" @return       
	" .cmd    = 'p4 opened'
	" .client = '-p localhost:1818'
	" .outs   = ['']
	" ********************************************************************************
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
	" ********************************************************************************
	" @param[in]     a:clients[] = '-p localhost:1818'
	" @param[in]     a:pfcmd     = 'opened'
	" @param[in]     a:head      = ''
	" @param[in]     a:tail      = ''
	"
	" @return []
	" .cmd    = 'p4 opened'
	" .client = '-p localhost:1818'
	" .outs[] = ''  
	" ********************************************************************************

	let kind = '__common'
	let foot_d = {}
	let foot_d.base = a:tail



	let max_ = perforce#data#get('g:unite_perforce_show_max', kind)
	if max_ > 0
		foot_d.max = '-m '.max_
	endif 

	if perforce#data#get('g:unite_perforce_user_changes_only',kind) == 1 
		let foot_d.user = '-u '.perforce#get#PFUSER()
	endif

	let rtns = []
	if perforce#data#get('g:unite_perforce_client_changes_only',kind) == 1
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
	" ********************************************************************************
	" @param[in] a:pfcmd
	" @param[in] a:head
	" @param[in] a:tail
	"
	" @return  datas
	" [].client'  =  '' 
	" [].cmd      =  ''  - p4 opened
	" [].outs     =  []  - cmd outputs
	" ********************************************************************************
	let clients = perforce#get#clients()
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
function! perforce#cmd#main(pfcmd) "{{{
	" ********************************************************************************
	" @param[in] a:pfcmd = 'clients'
	"
	" @return
	" .cmd    = 'p4 clients'
	" .outs[] = ''
	" ********************************************************************************
	if a:pfcmd == 'clients'
		return s:pfcmds_port_only('clients', '', '')
	endif
endfunction
"}}}
" now making
function! perforce#cmd#files(pfcmd, files, have_flg) "{{{
	" ********************************************************************************
	" @param[in]   a:pfcmd       = 'diff'
	" @param[in]   a:files[]     = ''
	" @param[in]   a:have_flg[]  = 1 ot 0 - (1:true, 0:false, -1:true and false)
	"
	" @return      
	" [].cmd     = 'p4 edit'
	" [].outs[]  = '' - cmd output line
	"
	" @par 2013/05/06
	" ********************************************************************************
	let pfcmd = a:pfcmd

	let pfcmds = [
				\ 'diff'
				\ ]
	if a:pfcmd =~ join(pfcmds, '\|')
		if perforce#data#get('g:unite_perforce_diff_dw', 'common') == 1
			let pfcmd = 'diff -dw'
		endif
	endif

	let pfcmds = [
				\ 'edit',
				\ 'add',
				\ 'revert -a',
				\ 'revert',
				\ 'print -q',
				\ ]
	if a:pfcmd =~ join(pfcmds, '\|')
		" DO NOTHING
	endif

	let rtn_ds = []

	if a:have_flg == 1
		let have_types = ['true']
	elseif a:have_flg == 0
		let have_types = ['false']
	else
		let have_types = ['true', 'false']
	endif

	let data_d = perforce#is_p4_haves_client2(a:files)
	for have_type in have_types
		for client in keys(data_d[have_type])
			let files = data_d.true[client]
			call extend(rtn_ds, perforce#cmd#clients#files(client, pfcmd, files))
		endfor
	endfor

	return rtn_ds
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

