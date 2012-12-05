 let s:save_cpo = &cpo
 set cpo&vim

let s:O = vital#of('unite-perforce.vim').import("Mind.Common")

function! perforce#common#MyQuit(...)
	return call(s:O.MyQuit, a:000)
endfunction
function! perforce#common#get_kk(...)
	return call(s:O.get_kk, a:000)
endfunction
function! perforce#common#LogFile(...)
	return call(s:O.LogFile, a:000)
endfunction
function! perforce#common#get_pathSrash(...)
	return call(s:O.get_pathSrash, a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

