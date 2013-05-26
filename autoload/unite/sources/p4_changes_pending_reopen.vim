let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_changes_pending_reopen#define()
	return s:source_p4_changes_pending_reopen
endfunction

let s:source_p4_changes_pending_reopen = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : 'チェンジリストの移動',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'default_kind' : 'k_p4_change_pending',
			\ 'hooks' : {},
			\ }
let s:source_p4_changes_pending_reopen.hooks.on_init     = function('perforce#get#fname#for_unite')
let s:source_p4_changes_pending_reopen.gather_candidates = function('pf_changes#gather_candidates')
let s:source_p4_changes_pending_reopen.change_candidates = function('pf_changes#change_candidates')

call unite#define_source(s:source_p4_changes_pending_reopen)

let &cpo = s:save_cpo
unlet s:save_cpo
