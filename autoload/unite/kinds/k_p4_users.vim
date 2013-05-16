let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_users#define()
	return s:kind
endfunction

let s:kind = { 
			\ 'name' : 'k_p4_users',
			\ 'default_action' : 'a_p4_user_change',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_user_change = {
			\ 'description' : '���[�U�[�̐؂�ւ�',
			\ }
function! s:kind.action_table.a_p4_user_change.func(candidates) "{{{
	let candidate = a:candidates
	let user = candidate.action__user
	let outs = perforce#set#PFUSER(user)
	call perforce#LogFile(outs)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

