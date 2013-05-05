let s:save_cpo = &cpo
set cpo&vim

function! s:cmd(cmd) "{{{
	let cmd = a:cmd
	echo cmd 
	call unite#print_message('[cmd - clients] '.cmd)
	let outs = split(system(cmd), '\n')
	return outs
endfunction
"}}}
function! perforce#cmd#base#main(pfcmd, header, footer)  "{{{
	" ********************************************************************************
	" @param[in]     a:client    = '-p localhost:1818 -c origin'
	" @param[in]     a:pfcmd     = ''
	" @param[in]     a:header    = ''
	" @param[in]     a:footer    = ''
	"
	" @return data_d
	" .cmd      =  ['p4 edit']
	" .outs     =  []
	"
	" @par ˆê”Ô
	" ********************************************************************************
	let cmd    = 'p4 '.a:header.' '.a:pfcmd.' '.a:footer
	let outs   = s:cmd(cmd)
	let data_d = {
				\ 'cmd'  : cmd,
				\ 'outs' : outs,
				\ }
	return data_d
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
