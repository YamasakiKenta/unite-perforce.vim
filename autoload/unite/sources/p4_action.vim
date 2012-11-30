function! unite#sources#p4_action#define()
	"return s:source__p4_action
	return []
endfunction

if 0
"source - p4_action
let s:source = {
			\ 'name'           : 'p4_action',
			\ 'description'    : '',
			\ 'default_action' : '',
			\ }
call unite#define_source(s:source)
function! s:source.gather_candidates(args, context)
	let datas = [

	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'file',
				\ }")
	return candidates
endfunction
unlet s:sourcelet s:save_cpo = &cpo
set cpo&vim


endif

let &cpo = s:save_cpo
unlet s:save_cpo

