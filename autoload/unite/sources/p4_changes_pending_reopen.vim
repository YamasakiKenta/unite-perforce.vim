let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_changes_pending_reopen#define()
	return s:source_p4_changes_pending_reopen
endfunction

let s:source_p4_changes_pending_reopen = {
			\ 'name'           : 'p4/changes_pending_reopen',
			\ 'description'    : 'チェンジリストの移動',
			\ 'default_kind'   : 'k_p4_change_reopen',
			\ 'hooks'          : {},
			\ }
function s:source_p4_changes_pending_reopen.hooks.on_init(...)
	return call('perforce#get#fname#for_unite', a:000)
endfunction
function s:source_p4_changes_pending_reopen.gather_candidates(...)
	return call('pf_changes#gather_candidates', a:000 + ['pending'])
endfunction
function s:source_p4_changes_pending_reopen.change_candidates(...)
	return call('pf_changes#change_candidates', a:000)
endfunction

call unite#define_source(s:source_p4_changes_pending_reopen)

let &cpo = s:save_cpo
unlet s:save_cpo
