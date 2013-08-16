let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_jobs#define()
	return s:k_p4_jobs
endfunction

function! s:get_job_from_jobs(candidate) 
	" [2013-06-07 01:27]
	return matchstr(a:candidate.action__out, '\S*')
endfunction

let s:k_p4_jobs = { 
			\ 'name'           : 'k_p4_jobs',
			\ 'action_table'   : {},
			\ 'parents'        : ['k_p4'],
			\ 'default_action' : 'a_p4_fixes',
			\ }

let s:k_p4_jobs.action_table.a_p4_fixes = { 
			\ 'is_selectable' : 1,
			\ 'description'   : 'ジョブの情報',
			\ 'is_quit'       : 0,
			\ }
function! s:k_p4_jobs.action_table.a_p4_fixes.func(candidates) "{{{
	" [2013-06-07 01:34]
	let data_ds = []
	for candidate in a:candidates
		" チェンジリストの番号の取得をする
		let port_client = candidate.action__client
		let data_d= {
					\ 'job'    : s:get_job_from_jobs(candidate),
					\ 'client' : port_client,
					\ }
		call add(data_ds, data_d)
	endfor

	call unite#start_temporary([insert(data_ds, 'p4_fixes')]) 
endfunction
"}}}

call unite#define_kind(s:k_p4_jobs) 

let &cpo = s:save_cpo
unlet s:save_cpo

