let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perforce.vim')
let s:Common   = s:V.import('Mind.Common')
let s:Perforce = s:V.import('Mind.Perforce')
let s:File     = s:V.import('Mind.Y_files')
let s:Tab      = s:V.import('Mind.Tab')

function! perforce#util#get_files(...)
	return call(s:File.get_files, a:000)
endfunction

function! perforce#util#get_client_root(...) 
	return call(s:Perforce.get_client_root, a:000)
endfunction 

function! perforce#util#get_client_root_from_client(...)
	return call(s:Perforce.get_client_root_from_client, a:000)
endfunction

function! perforce#util#event_save_file(...)
	return call(s:Common.event_save_file, a:000)
endfunction

function! perforce#util#map_diff(...)
	return call(s:Common.map_diff, a:000)
endfunction

function! perforce#util#open_lines(...)
	return call(s:Tab.open_lines, a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
