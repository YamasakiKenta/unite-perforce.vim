function! unite#sources#p4_jobs#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_jobs',
			\ 'description' : 'ƒWƒ‡ƒu‚Ì•\Ž¦',
			\ }
function! s:get_job_from_jobs(str) "{{{
	return substitute(a:str,'\(\S*\).*','\1','')
	
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#pfcmds('jobs')
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_p4_jobs',
				\ 'action__job' : <SID>get_job_from_jobs(v:val),
				\ }")
	return candidates
endfunction "}}}
