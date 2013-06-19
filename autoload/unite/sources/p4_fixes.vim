let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_fixes#define()
	return s:source_p4_fixes
endfunction

function! s:get_chnum_from_fixes(str) "{{{
	return matchstr(a:str, 'change \zs\d\+')
endfunction
"}}}

let s:source_p4_fixes = {
			\ 'name'           : 'p4_fixes',
			\ 'description'    : '',
			\ 'default_action' : 'a_p4change_describe',
			\ 'default_kind'   : 'k_p4_change_pending',
			\ }
function! s:source_p4_fixes.gather_candidates(args, context) "{{{

	let data_ds = perforce#source#get_data_client('-j ', 'job', a:args)

	let tmps = []
	for data_d in data_ds
		let job          = data_d.job
		let use_ports    = data_d.use_ports
		call extend(tmps, perforce#cmd#clients(use_ports, 'p4 fixes '.job))
	endfor

	let candidates = []
	for tmp in tmps
		let client = tmp.client
		call extend(candidates, map( tmp.outs, "{
					\ 'word' : client.' : '.v:val,
					\ 'action__chnum'  : s:get_chnum_from_fixes(v:val),
					\ 'action__client' : client,
					\ 'action__out'    : v:val,
					\ }"))

	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source_p4_fixes)

let &cpo = s:save_cpo
unlet s:save_cpo
