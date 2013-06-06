let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_jobs#define()
	return s:source_jobs
endfunction

let s:source_jobs = {
			\ 'name'         : 'p4_jobs',
			\ 'description'  : 'ƒWƒ‡ƒu‚Ì•\Ž¦',
			\ 'default_kind' : 'k_p4_jobs',
			\ }
function! s:source_jobs.gather_candidates(args, context) "{{{
	" [2013-06-07 01:34]
	let use_ports = perforce#data#get_use_ports()
	let datas     = perforce#cmd#clients(use_ports, 'p4 jobs')

	let candidates = []
	for data in datas
		call extend(candidates, map(data.outs, "{
					\ 'word' : data.client.' : '.v:val,
					\ 'action__out' : v:val,
					\ }"))
	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source_jobs)

let &cpo = s:save_cpo
unlet s:save_cpo

