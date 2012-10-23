function! unite#sources#p4_info#define()
	return [s:source]
endfunction

"source - p4_info "{{{
let s:source = {
			\ 'name' : 'p4_info',
			\ 'description' : 'show p4 info',
			\ }
"\ 'default_action' : '',
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#pfcmds('info','').outs
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_null',
				\ }")
	return candidates
endfunction "}}}
