let s:save_cpo = &cpo
set cpo&vim

function! s:system(cmd) "{{{
	if exists('s:exists_vimproc')
		let data = vimproc#system(a:cmd)
	else
		let data = system(a:cmd)
	endif
	return data
endfunction 
"}}}

let s:cache_client = ' '
let s:cache_port   = ' '

function! s:get_set_data(str) 
	return matchstr(s:system('p4 set '.a:str), '\w*=\zs.* \ze(set)')
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

function! perforce#get#clients() "{{{
	let clients = perforce#data#get('g:unite_perforce_clients')

	if len(clients) < 1
		let clients = [s:cache_port.' '.s:cache_client]
	endif

	return clients
endfunction
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

