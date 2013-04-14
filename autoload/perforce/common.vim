let s:save_cpo = &cpo
set cpo&vim

let s:Vital  = vital#of('unite-perforce.vim')
let s:Common = s:Vital.import("Mind.Common")
let s:List   = s:Vital.import('Data.List')

function! perforce#common#get_kk(...)
	return call(s:Common.get_kk, a:000)
endfunction
function! perforce#common#LogFile(...)
	return call(s:Common.LogFile, a:000)
endfunction
function! perforce#common#get_pathSrash(...)
	return call(s:Common.get_pathSrash, a:000)
endfunction
function! perforce#common#uniq(...)
	return call(s:List.uniq, a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

