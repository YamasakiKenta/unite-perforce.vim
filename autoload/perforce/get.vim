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

function! s:get_set_data(str) 
	return matchstr(s:system('p4 set '.a:str), '\w*=\zs.* \ze(set)')
endfunction 

function! perforce#get#PFCLIENTPATH(...) 
	return call('perforce#util#get_client_root', a:000)
endfunction 

function! perforce#get#PFCLIENTNAME() 
	return s:get_set_data('P4CLIENT')
endfunction 

function! perforce#get#PFPORT() 
	return s:get_set_data('P4PORT')
endfunction 

function! perforce#get#PFUSER() 
	return s:get_set_data('P4USER')
endfunction 

let &cpo = s:save_cpo
unlet s:save_cpo

