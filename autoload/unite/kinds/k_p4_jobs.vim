let s:save_cpo = &cpo
set cpo&vim


function! unite#kinds#k_p4_jobs#define()
	return s:k_p4_jobs
endfunction

function! s:get_job_from_jobs(str) 
	" [2013-06-07 01:27]
	return matchstr(a:str, '\S*')
endfunction

let s:k_p4_jobs = { 
			\ 'name' : 'k_p4_jobs',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ 'default_action' : 'a_p4_fixes',
			\ }

let s:k_p4_jobs.action_table.a_p4_fixes = { 
			\ 'is_selectable' : 1,
			\ 'description'   : 'ÉWÉáÉuÇÃèÓïÒ',
			\ 'is_quit'       : 0,
			\ }
function! s:k_p4_jobs.action_table.a_p4_fixes.func(candidates) "{{{
	let jobs = map(deepcopy(a:candidates),"s:get_job_from_jobs(v:val.action__out)")
	call unite#start_temporary([insert(jobs, 'p4_fixes')]) 
endfunction
"}}}

if 1
	call unite#define_kind(s:k_p4_jobs) 
endif

let &cpo = s:save_cpo
unlet s:save_cpo

