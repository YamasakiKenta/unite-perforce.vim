let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_help#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4/help',
			\ 'default_kind' : 'k_p4_help',
			\ }
function! s:get_pfcmd_from_help(str) "{{{
	return substitute(a:str,'\t\(\w\+\) .*','\1','')
endfunction
"}}}
function! s:source.gather_candidates(args, context) "{{{
	" [2013-06-07 07:56]
	let datas = split(perforce#system('p4 help commands'), "\n")
	unlet datas[0:1]
	let candidates = map( datas, "{
				\ 'word' : substitute(v:val,'\t','',''),
				\ 'action__cmd' : s:get_pfcmd_from_help(v:val),
				\ 'action__out' : v:val,
				\ }")
	return candidates
endfunction
"}}}
"
call unite#define_source(s:source)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set &cpo
endif

