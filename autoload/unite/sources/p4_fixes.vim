let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8
function! s:get_chnum_from_fixes(str)
	return matchstr(a:str, 'change \zs\d\+')
endfunction

function! unite#sources#p4_fixes#define()
	"return s:source_p4_fixes
	return []
endfunction

"source - p4_fixes
let s:source = {
			\ 'name'           : 'p4_fixes',
			\ 'description'    : '',
			\ 'default_action' : 'a_p4change_describe',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" @par       
	" @param[in]  list  a:args  jobs name
	" @retval      unite data
	" ********************************************************************************
	let jobs = copy(a:args)
	let hut = join(map(jobs, "'-j '.v:val"))

	let data_d = perforce#pfcmds_new('fixes', '', hut)

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

call unite#define_source(s:source_p4_fixes)

let &cpo = s:save_cpo
unlet s:save_cpo
