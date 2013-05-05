let s:save_cpo = &cpo
set cpo&vim

function! s:perforce_cmd_clients_main(clients, pfcmd, ...) "{{{
	let header_base = get(a:, 1, '')
	let footer      = get(a:, 2, '')
	
	let data_ds = []

	" ない場合は、空白をセットする
	let clients = len(a:clients) ? [' '] : a:clients

	for client in clients 
		let header = client.' '.header_base
		let data_d = perforce#cmd#base#main(a:pfcmd, header, footer)
		call add(data_ds, data_d)
	endfor

	return data_ds
endfunction
"}}}
function! perforce#cmd#clients#files(clients, pfcmd, files) "{{{
	" ********************************************************************************
	" @param[in]     a:clients[] = '-p localhost:1818 -c origin'
	"
	" @return data_ds
	" [].cmd      =  ''  - p4 opened
	" [].outs     =  []  - cmd outputs
	" ********************************************************************************
	"
	let header = ''
	let footer = '"'.join(a:files, '" "').'"'
	return s:perforce_cmd_clients_main(a:clients, a:pfcmd, header, footer)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
