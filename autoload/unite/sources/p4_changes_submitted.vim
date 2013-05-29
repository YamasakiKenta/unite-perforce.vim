let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_changes_submitted#define()
	return s:source_p4_changes_submitted
endfunction

let s:source_p4_changes_submitted = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit 済みチェンジリスト',
			\ 'hooks' : {},
			\ 'default_kind' : 'k_p4_change_submitted',
			\ }

let s:source_p4_changes_submitted.hooks.on_init = function('perforce#get#fname#for_unite')
function s:source_p4_changes_submitted.gather_candidates(...)
	return call('pf_changes#gather_candidates', a:000 + ['submitted'])
endfunction

call unite#define_source(s:source_p4_changes_submitted)

let &cpo = s:save_cpo
unlet s:save_cpo
