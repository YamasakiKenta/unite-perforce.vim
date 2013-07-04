let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_depot#define()
	return s:kind_depot
endfunction

function! s:get_port_client_files(candidates) "{{{
	" ********************************************************************************
	" [2013-06-08 20:32]
	" @return        { port_client = [file] }
	" ********************************************************************************
	let file_d = {}
	let default_port_clients = perforce#data#get_use_port_clients()
	for candidate in a:candidates

		if exists('candidate.action__client')
			let port_clients = [candidate.action__client]
		else
			let port_clients = deepcopy(default_port_clients)
		endif

		call input(string(port_clients))

		for port_client in port_clients
			if !exists('file_d[port_client]')
				let file_d[port_client] = []
			endif
			if exists('candidate.action__depot')
				let path = candidate.action__depot
			elseif exists('candidate.action__path')
				let path = candidate.action__path
			endif
			call add(file_d[port_client], path)
		endfor
	endfor

	return file_d
endfunction
"}}}
function! s:sub_action(candidates, cmd) "{{{
	" [2013-06-08 20:32]
	let file_d = s:get_port_client_files(a:candidates)
	let datas  = perforce#cmd#client_files(file_d, a:cmd)
	let outs   = perforce#extend_dicts('outs', datas)
	return outs
endfunction
"}}}
function! pf_action#sub_action_log(candidates, cmd) "{{{
	" [2013-06-08 20:32]
	let outs = s:sub_action(a:candidates, a:cmd)
	call perforce#log_file(outs)
	return outs
endfunction
"}}}

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif

