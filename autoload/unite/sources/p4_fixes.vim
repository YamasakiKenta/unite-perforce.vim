let s:save_cpo = &cpo
set cpo&vim
function! s:get_chnum_from_fixes(str)
	return matchstr(a:str, 'change \zs\d\+')
endfunction

function! unite#sources#p4_fixes#define()
	return s:source_p4_fixes
endfunction

"source - p4_fixes
let s:source = {
			\ 'name'           : 'p4_fixes',
			\ 'description'    : '',
			\ 'default_action' : 'a_p4change_describe',
			\ }
call unite#define_source(s:source)
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" @par       
	" @param[in]  list  a:args  jobs name
	" @retval      unite data
	" ********************************************************************************
	let jobs = a:args

	let data_d = perforce#pfcmds_new('fixes', '', join(map(jobs, "'-j '.v:val")))

	let candidates = []

	for data in data_d
		let client = data.client
	let candidates = map( data.outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_p4_change',
				\ 'action__chnum' : s:get_chnum_from_fixes(v:val),
				\ 'action__client' : client,
				\ }")

	endfor

	return candidates
endfunction
"}}}

let s:source_p4_fixes = deepcopy(s:source) | unlet s:source

let &cpo = s:save_cpo
unlet s:save_cpo
