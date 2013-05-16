let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_jobs#define()
	return s:source_jobs
endfunction

let s:source_jobs = {
			\ 'name' : 'p4_jobs',
			\ 'description' : 'ƒWƒ‡ƒu‚Ì•\Ž¦',
			\ }
function! s:get_job_from_jobs(str) "{{{
	return matchstr(a:str, '\S*')
endfunction
"}}}
function! s:source_jobs.gather_candidates(args, context) "{{{
	let datas = perforce#cmd#base('jobs','').outs
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_p4_jobs',
				\ 'action__job' : s:get_job_from_jobs(v:val),
				\ }")
	return candidates
endfunction
"}}}

if 1
	call unite#define_source(s:source_jobs)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

