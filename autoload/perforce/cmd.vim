let s:save_cpo = &cpo
set cpo&vim

function! s:pfcmds_new_get_outs(datas) "{{{
	" ********************************************************************************
	" @param[in]  datas
	" .cmd      = 'p4 opened'
	" .client   = '-p localhost:1818 -c origin'
	" .outs[]   = ''
	"
	" @return    outs[] = '' - �o�͌��ʂ��܂Ƃ߂�
	" ********************************************************************************
	let outs = []
	for data in a:datas
		call extend(outs, get(data, 'outs', []))
	endfor

	return outs
endfunction
"}}}

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
	
	let client_default_flg = perforce#data#get('g:unite_perforce_use_default')
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
	let clients = perforce#data#get('g:unite_perforce_clients')
	return  s:pfcmds_with_clients_and_unite_mes(clients, a:pfcmd, a:head, a:tail)
endfunction
"}}}
function! perforce#cmd#new_outs(pfcmd, head, tail) "{{{
	" ********************************************************************************
	" @param[in]    a:pfcmd  = 'opened'
	" @param[in]    a:head   = ''
	" @param[in]    a:tail   = ''
	"
	" @return       rtns[]
	" .client' = '-p localhost:1818 -c origin' 
	" .cmd     = 'p4 opened'
	" .outs[]  = ''  - cmd outputs
	" ********************************************************************************
	let client_default_flg = perforce#data#get('g:unite_perforce_use_default')
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

	let client_default_flg = perforce#data#get('g:unite_perforce_use_default')
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

	" Error �̏ꍇ�́A�o�͂�ύX����
	let rtn_d.outs = s:conv_error(rtn_d.outs)

	call unite#print_message(rtn_d.cmd)

	" ��\���ɂ���R�}���h
	let filters_ = perforce#data#get('g:unite_perforce_filters')
	if len(join(filters_) > 0
		let filter_ = join(filters, '\|' ) 
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
	" @par           �G���[�������ɁA�Ȍ��ɂ���
	" @param[in]     a:outs[] = '' - �o�͌���
	"
	" @return        outs[]  = 'ERROR'  - �G���[���́AERROR�ɕύX����
	" @return        outs[]  = a:outs[] - �ʏ펞�́A���̂܂ܕԂ�
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
	" @return        outs[] = '' - �o�͌���
	" ********************************************************************************
	" @par filter ���������l��Ԃ��܂�
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
	" @par  �R�}���h���Ɏg�p���� �������擾����
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
		 	let foot_d.client = '-c '.client " ����
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
	let clients = perforce#data#get('g:unite_perforce_clients')
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
function! perforce#cmd#files(pfcmd, files) "{{{
	" ********************************************************************************
	" @param[in]   a:pfcmd    = 'diff'
	" @param[in]   a:files[]  = ''
	"
	" @return      
	" .cmd     = 'p4 edit'
	" .outs[]  = ''
	" ********************************************************************************
	"
	if a:pfcmd == 'diff'
		if perforce#data#get('g:unite_perforce_diff_dw', 'common') == 1
		endif
	endif

	if a:pfcmd == 'edit' || a:pfcmd == 'add'
	endif
	return perforce#cmd#new(a:pfcmd, '', join(a:files))
endfunction
"}}}
function! perforce#cmd#files_outs(pfcmd, files) "{{{
	" ********************************************************************************
	" @param[in]   a:pfcmd    = 'diff'
	" @param[in]   a:files[]  = ''
	"
	" @return      
	" .cmd     = 'p4 edit'
	" .outs[]  = ''
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

	if len(a:files) > 0
		let outs = perforce#cmd#new_outs(pfcmd, '', join(a:files))
	else
		let outs = []
	endif

	return outs

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

