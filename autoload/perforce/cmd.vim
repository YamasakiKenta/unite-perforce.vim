let s:save_cpo = &cpo
set cpo&vim

function! s:is_p4_have_from_have(port_client, file) "{{{
	" [2013-06-07 01:02]
	let cmd = printf('p4 -s %s have %s', a:port_client, perforce#get_kk(a:file))
	let str = perforce#system(cmd)
	return ( str =~ '^error: ' ) ? 0 : 1
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
			if s:is_p4_have_from_have(port_client, file_) == 1
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

function! perforce#cmd#clients(clients, cmd) "{{{
	let cmd_base = a:cmd
	let cmd_base = substitute(cmd_base, 'p4', '', '')

	let rtn_ds = []
	let msgs = []
	for client in a:clients
		let cmd = printf('p4 %s %s', client, cmd_base)
		call add(msgs, cmd)

		let outs = split(perforce#system(cmd), "\n")

		" filter
		let outs = s:get_outs(outs)

		if !s:is_error(outs)
			call add(rtn_ds, {
						\ 'cmd'    : cmd,
						\ 'outs'   : outs,
						\ 'client' : client,
						\ })
		endif
	endfor

	" message
	call unite#print_message(string(msgs))
	call input("")
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
		let files = a:datas[port_client]
		if len(files) > 0
			call map(files, "fnamemodify(v:val, ':p')")
			let file_ = '"'.join(files, '" "').'"'
			let cmd   = a:cmd.' '.file_
			let tmps  = perforce#cmd#clients([port_client], cmd)
			call extend(rtns, tmps)
		endif
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
function! perforce#cmd#use_port_clients_files(cmd, files, have_flg) "{{{

	if a:have_flg == 1
		let have_types = ['true']
	elseif a:have_flg == 0
		let have_types = ['false']
	else
		let have_types = ['true', 'false']
	endif

	let data_d = s:is_p4_haves_client(a:files)

	let rtns = []
	for have_type in have_types
		let tmps = data_d[have_type]
		call extend(rtns, perforce#cmd#client_files(tmps, a:cmd))
	endfor

	return rtns
endfunction
"}}}

function! s:is_error(outs)
	let rtn = 0
	if ( len(a:outs) > 0 ) &&  (type(a:outs) == type([]))
		if a:outs[0] =~ 'An empty string is not allowed as a file name.'
			let rtn = 1
		endif
	endif
	return rtn
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

