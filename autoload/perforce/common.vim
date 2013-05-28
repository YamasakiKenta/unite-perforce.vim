let s:save_cpo = &cpo
set cpo&vim

let s:Vital  = vital#of('unite-perforce.vim')
let s:Common = s:Vital.import("Mind.Common")
let s:List   = s:Vital.import('Data.List')

function! perforce#get_kk(...)
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

