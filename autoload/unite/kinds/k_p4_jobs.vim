function! unite#kinds#k_p4_jobs#define()
	return s:kind
endfunction

let s:kind = { 
			\ 'name' : 'k_p4_jobs',
			\ 'action_table' : {},
			\ 'parents' : [],
			\ }

let s:kind.action_table.a_p4_fixes = { 
			\ 'is_selectable' : 1, 
			\ 'description' : 'ジョブの情報',
			\ 'default_action' : 'a_p4_fixes',
			\ }
function! s:kind.action_table.a_p4_fixes.func(candidates) "{{{
	let jobs = map(copy(a:candidates),"v:val.action__job")
	let outs = perforce#cmds('fixes '.perforce#get_PFUSER().' '.'-j '.join(jobs,'-j '))
endfunction "}}}
