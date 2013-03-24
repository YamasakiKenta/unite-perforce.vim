let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8


function! unite#sources#p4_jobs#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_jobs',
			\ 'description' : 'ジョブの表示',
			\ }
function! s:get_job_from_jobs(str) "{{{
	return substitute(a:str,'\(\S*\).*','\1','')
	
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{
	let datas = perforce#pfcmds('jobs','').outs
	let candidates = map( datas, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_p4_jobs',
				\ 'action__job' : s:get_job_from_jobs(v:val),
				\ }")
	return candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

