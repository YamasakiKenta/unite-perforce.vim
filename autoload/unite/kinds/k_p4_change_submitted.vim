let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_change_submitted#define()
	return s:kind_k_p4_change_submitted
endfunction

let s:kind_k_p4_change_submitted = {
			\ 'name' : 'k_p4_change_submitted',
			\ 'default_action' : 'a_p4change_describe',
			\ 'parents'        : ['s:kind_k_p4_change_pending'],
			\ }

call unite#define_kind(s:kind_k_p4_change_submitted)

let &cpo = s:save_cpo
unlet s:save_cpo
