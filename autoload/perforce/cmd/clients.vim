let s:save_cpo = &cpo
set cpo&vim

function! perforce#cmd#clients#main(clients, pfcmds)
	" ********************************************************************************
	" @param[in]     a:clients[] = '-p localhost:1818 -c origin'
	" [].client'  =  '' 
	" [].cmd      =  ''  - p4 opened
	" [].outs     =  []  - cmd outputs
	" ********************************************************************************
	"
	let data_d = {}
	return data_d
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
