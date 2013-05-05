let s:save_cpo = &cpo
set cpo&vim

function! s:cmd(cmd) "{{{
	let cmd = a:cmd
	echo cmd 
	call unite#print_message('[cmd] '.cmd)
	let outs = split(system(cmd), '\n')
	return outs
endfunction
"}}}

function! s:perforce_cmd_clients_base(client, pfcmd, header, footer)  "{{{
	" ********************************************************************************
	" @param[in]     a:client    = '-p localhost:1818 -c origin'
	" @param[in]     a:pfcmd     = ''
	" @param[in]     a:header    = ''
	" @param[in]     a:footer    = ''
	"
	" @return data_d
	" .cmd      =  ['p4 edit']
	" .outs     =  []
	" ********************************************************************************
	let cmd    = 'p4 '.a:client.' '.a:header.' '.a:pfcmd.' '.a:footer
	let outs   = s:cmd(cmd)
	let data_d = {
				\ 'cmd'  : cmd,
				\ 'outs' : outs,
				\ }
	return data_d
endfunction
"}}}
function! s:perforce_cmd_clients_main(clients, pfcmd, ...) "{{{
	" ********************************************************************************
	" @param[in]     a:clients[] = ['-p localhost:1818 -c origin']
	" @param[in]     a:pfcmd     = 'edit'
	" @param[in]     a:1         = '' - header
	" @param[in]     a:2         = '' - footer
	"
	" @return data_d
	" [].cmd      =  'p4 edit'
	" [].outs     =  []
	" ********************************************************************************
	"
	let header = get(a:, 1, '')
	let footer = get(a:, 2, '')
	
	let data_ds = []
	for client in a:clients 
		let data_d = s:perforce_cmd_clients_base(client, a:pfcmd, header, footer)
		call add(data_ds, data_d)
	endfor

	return data_ds
endfunction
"}}}
function! s:perforce_cmd_clients_files(clients, pfcmd, files) "{{{
	" ********************************************************************************
	" @param[in]     a:clients[] = '-p localhost:1818 -c origin'
	"
	" @return data_ds
	" [].cmd      =  ''  - p4 opened
	" [].outs     =  []  - cmd outputs
	" ********************************************************************************
	
	let header = ''
	let footer = '"'.join(a:files, '" "').'"'
	return s:perforce_cmd_clients_main(a:clients, a:pfcmd, header, footer)
endfunction
"}}}

function! perforce#cmd#clients#files_outs(clients, pfcmd, files) "{{{
	let outs    = []
	let data_ds = s:perforce_cmd_clients_files(a:clients, a:pfcmd, a:files)
	for data_d in data_ds
		call extend(outs, data_d.outs)
	endfor
	return outs
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
