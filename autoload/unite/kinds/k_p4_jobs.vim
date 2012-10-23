function! unite#kinds#k_p4_jobs#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_jobs
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_jobs',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_fixes = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ÉWÉáÉuÇÃèÓïÒ',
			\ 'default_action' : 'a_p4_fixes',
			\ }
function! s:kind.action_table.a_p4_fixes.func(candidates) "{{{
	let jobs = map(copy(a:candidates),"v:val.action__job")
	let outs = perforce#pfcmds('fixes','',perforce#get_PFUSER().' '.'-j '.join(jobs,'-j ')).outs
endfunction "}}}
