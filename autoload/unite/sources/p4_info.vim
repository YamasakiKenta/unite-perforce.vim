function! unite#sources#p4_info#define()
	return []
endfunction

"source - p4_info "{{{
let s:source = {
			\ 'name' : 'p4_info',
			\ 'description' : 'show p4 info',
			\ }
"\ 'default_action' : '',
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#pf
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'file',
				\ }")
	return candidates
endfunction "}}}
unlet s:source "}}}
