let s:save_cpo = &cpo
set cpo&vim


function! unite#kinds#k_p4_jobs#define()
	return s:k_p4_jobs
endfunction

" ********************************************************************************
" kind - k_p4_jobs
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_jobs',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ 'default_action' : 'a_p4_fixes',
			\ }

let s:kind.action_table.a_p4_fixes = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ÉWÉáÉuÇÃèÓïÒ',
			\ 'default_action' : 'a_p4_fixes',
			\ }
function! s:kind.action_table.a_p4_fixes.func(candidates) "{{{
	let jobs = map(copy(a:candidates),"v:val.action__job")
	let data_d = perforce#pfcmds_new('fixes','','-j '.join(jobs,'-j '))

	let outs = []
	for data in data_d
		call extend(outs, data.outs)
	endfor

	let jobs = map(copy(outs), "matchstr(v:val, '\\w*')")
	let jobs = perforce#common#uniq(jobs)

	call unite#start_temporary([insert(jobs, 'p4_fixes')]) 
endfunction "}}}

let s:k_p4_jobs = deepcopy(s:kind)
call unite#define_kind(s:k_p4_jobs) | unlet s:k_p4_jobs

let &cpo = s:save_cpo
unlet s:save_cpo

