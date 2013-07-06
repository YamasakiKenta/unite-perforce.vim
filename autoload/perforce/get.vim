let s:save_cpo = &cpo
set cpo&vim

let s:cache_client = ''
let s:cache_port   = ''

function! s:get_set_data(str) 
	return matchstr(perforce#system('p4 set '.a:str), '\w*=\zs.* \ze(set)')
endfunction 

function! perforce#get#PFCLIENTPATH(...) 
	return call('perforce#util#get_client_root', a:000)
endfunction 

function! perforce#get#PFCLIENTNAME() 
	let client = s:get_set_data('P4CLIENT')
	let s:cache_client = '-c '.client
	return client
endfunction 

function! perforce#get#PFPORT() 
	let port   = s:get_set_data('P4PORT')
	let s:cache_port = '-p '.port
	return port
endfunction 

function! perforce#get#PFUSER() 
	return s:get_set_data('P4USER')
endfunction 

function! perforce#get#outs(data_ds) "{{{
	" ********************************************************************************
	" @param[in]  datas
	" .cmd      = 'p4 opened'
	" .client   = '-p localhost:1818 -c origin'
	" .outs[]   = ''
	"
	" @return    outs[] = '' - èoóÕåãâ ÇÇ‹Ç∆ÇﬂÇÈ
	" ********************************************************************************
	let outs = []
	for data_d in a:data_ds
		call extend(outs, get(data_d, 'outs', []))
	endfor
	return outs
endfunction
"}}}


function! perforce#get#cache_port()
	if len(s:cache_port) == 0
		call perforce#get#PFPORT()
	endif
	return s:cache_port
endfunction

function! perforce#get#cache_client()
	if len(s:cache_client) == 0
		call perforce#get#PFCLIENTNAME()
	endif
	return s:cache_client
endfunction

function! perforce#get#cache_port_client()
	return perforce#get#cache_port().' '.perforce#get#cache_client()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

