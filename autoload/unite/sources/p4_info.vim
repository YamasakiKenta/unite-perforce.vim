let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_info#define()
	return s:source_p4_info
endfunction

"source - p4_info "{{{
let s:source_p4_info = {
			\ 'name' : 'p4_info',
			\ 'description' : 'show p4 info',
			\ }
"\ 'default_action' : '',
function! s:source_p4_info.gather_candidates(args, context) "{{{
	let datas = perforce#pfcmds('info','').outs
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ }")
	return candidates
endfunction "}}}

if 1
	call unite#define_source( s:source_p4_info )
endif

let &cpo = s:save_cpo
unlet s:save_cpo

