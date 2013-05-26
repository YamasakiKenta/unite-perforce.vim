let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_changes_submitted#define()
	return s:source_p4_changes_submitted
endfunction

let s:source_p4_changes_submitted = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit 済みチェンジリスト',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4change_describe',
			\ 'default_kind' : 'k_p4_change_submitted',
			\ }

let s:source_p4_changes_submitted.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_submitted.gather_candidates(args, context)
	let data_ds = perforce#cmd#new('changes','','-s submitted')
	return pf_changes#get(a:context, data_ds)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
