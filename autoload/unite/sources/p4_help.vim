let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8


function! unite#sources#p4_help#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_help',
			\ 'description' : 'ヘルプを表示',
			\ }
function! s:get_pfcmd_from_help(str) "{{{
	return substitute(a:str,'\t\(\w\+\) .*','\1','')
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#pfcmds('help','','commands').outs
	unlet datas[0:1]
	let candidates = map( datas, "{
				\ 'word' : substitute(v:val,'\t','',''),
				\ 'kind' : 'k_p4_help',
				\ 'action__cmd' : s:get_pfcmd_from_help(v:val),
				\ }")
	return candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

