let s:save_cpo = &cpo
set cpo&vim

function! s:is_p4_have_from_have(str) "{{{
	" [2013-06-07 01:02]
	return ( a:str =~ '- file(s) not on client.' ) ? 0 : 1
endfunction
"}}}
function! s:is_p4_haves_client(files) "{{{
	" [2013-06-07 01:10]
	" ********************************************************************************
	" クライアントにファイルがあるか調べる
	" @param[in]	files[] = '' - file name
	"
	" @return rtns_d
	" true.{port_client}[]    = '' -     have file name 
	" false.{port_client}[]   = '' - not have file name
	" ********************************************************************************
	"
	let port_clients = perforce#data#get_port_clients()
	let rtn_client_d = {}

	let rtns_d = {
				\ 'true'  : {},
				\ 'false' : {},
				\ }
	for port_client in port_clients

		let rtns_d.true[port_client]  = []
		let rtns_d.false[port_client] = []

		for file_ in a:files
			let str = system('p4 '.port_client.' have '.perforce#get_kk(file_))
			if s:is_p4_have_from_have(str) == 1
				let type = 'true'
			else
				let type = 'false'
			endif
			call add(rtns_d[type][port_client], file_)
		endfor

	endfor

	return rtns_d

endfunction
"}}}

function! s:get_outs(outs) "{{{
	" ********************************************************************************
	" @par フィルターをかける
	" ********************************************************************************
	let outs = copy(a:outs)

	let filters_ = perforce#data#get('g:unite_perforce_filters')
	if len(join(filters_)) > 0
		let filter_ = join( filters_, '\|' ) 
		call filter(outs, 'v:val !~ filter_')
	endif

	return outs
endfunction
"}}}

function! perforce#cmd#files(pfcmd, files, have_flg, onetime) "{{{
	" ********************************************************************************
	" @param[in]   a:pfcmd       = 'diff'
	" @param[in]   a:files[]     = ''
	" @param[in]   a:have_flg[]  = true / false 
	" @param[in]   a:onetime[]   = true / false 
	"                              最初に見つかったファイルのみ実行する
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

	let data_d = s:is_p4_haves_client(a:files)

	echo 'perforce#cmd#files -> '. string(data_d)
	for have_type in have_types
		for client in keys(data_d[have_type])
			let files = data_d[have_type][client]
			echo 'fiels -> '.string(files)
			let tmp_ds = perforce#cmd#clients#files([client], pfcmd, files)

			" ★ 上の関数で行う
			for tmp_d in tmp_ds
				if len(tmp_d.cmd)
					call add(rtn_ds, tmp_d)
				endif
			endfor
		endfor
	endfor

	return rtn_ds
endfunction
"}}}
function! perforce#cmd#clients(clients, cmd) "{{{
	let cmd_base = a:cmd
	let cmd_base = substitute(cmd_base, 'p4', '', '')

	let rtn_ds = []
	for client in a:clients
		let cmd = 'p4 '.client.' '.cmd_base
		call unite#print_message(cmd)

		let outs = split(system(cmd), "\n")
		let outs = s:get_outs(outs)

		call add(rtn_ds, {
					\ 'cmd'    : cmd,
					\ 'outs'   : outs,
					\ 'client' : client,
					\ })
	endfor
	return rtn_ds
endfunction
"}}}
function! perforce#cmd#client_files(datas, cmd) "{{{
	" ********************************************************************************
	" @param[in]     datas[port_client] = [file]
	" ********************************************************************************
	" ポート、ファイル名の取得
	let rtns = []
	for port_client in keys(a:datas)
		let files       = a:datas[port_client]
		let tmps        = perforce#cmd#clients#files([port_client], a:cmd, files)
		call extend(rtns, tmps)
	endfor

	return rtns
endfunction
"}}}

function! perforce#cmd#use_ports(cmd) "{{{
	let use_ports = perforce#data#get_use_ports()
	return perforce#cmd#clients(use_ports, a:cmd)
endfunction
"}}}
function! perforce#cmd#use_ports_max(cmd) "{{{
	let max = perforce#data#get_max()
	return perforce#cmd#use_ports(a:cmd.' '.max.' ')
endfunction
"}}}
function! perforce#cmd#use_port_clients(cmd) "{{{
	let use_port_clients = perforce#data#get_use_port_clients()
	return perforce#cmd#clients(use_port_clients, a:cmd)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

