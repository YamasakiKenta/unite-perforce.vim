let s:save_cpo = &cpo
set cpo&vim
function! s:get_chnum_from_fixes(str)
	return matchstr(a:str, 'change \zs\d\+')
endfunction

function! unite#sources#p4_fixes#define()
	return s:source_p4_fixes
endfunction

"source - p4_fixes
let s:source_p4_fixes = {
			\ 'name'           : 'p4_fixes',
			\ 'description'    : '',
			\ 'default_action' : 'a_p4change_describe',
			\ }
function! s:source_p4_fixes.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" @par       
	" @param[in]  list  a:args  jobs name
	" @retval      unite data
	" ********************************************************************************
	let jobs = copy(a:args)

	if len(a:args) > 0
		let jobs = copy(a:args)
	else
		call input("job name -> ")
	endif

	let data_ds = []
	for job in jobs
		call extend(data_ds, perforce#cmd#new('fixes', '', '-j '.job))
	endfor

	let candidates = []
	for data in data_ds
		let client = data.client
		call extend(candidates, map( data.outs, "{
					\ 'word' : client.' : '.v:val,
					\ 'kind' : 'k_p4_change_pending',
					\ 'action__chnum' : s:get_chnum_from_fixes(v:val),
					\ 'action__client' : client,
					\ 'action__out' : v:val,
					\ }"))

	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source_p4_fixes)

let &cpo = s:save_cpo
unlet s:save_cpo
