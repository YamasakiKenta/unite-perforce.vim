let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('unite-perforce.vim')
let s:Perforce = s:V.import('Mind.Perforce')
let s:Common = s:L.import('Mind.Common')

function! perforce#util#get_client_root_from_client(...)
	return call(s:Perforce.get_client_root_from_client, a:000)
endfunction

function! perforce#util#event_save_file(...)
	return call(s:Common.event_save_file, a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
