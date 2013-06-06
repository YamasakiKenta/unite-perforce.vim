let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_users#define()
	return s:kind
endfunction

function! s:get_UserName_from_users(candidate) "{{{
	return matchstr(a:candidate.action__out,'.\{-}\ze <.*')
endfunction
"}}}

let s:kind = { 
			\ 'name' : 'k_p4_users',
			\ 'default_action' : 'a_p4_user_change',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_user_change = {
			\ 'description' : 'ƒ†[ƒU[‚ÌØ‚è‘Ö‚¦',
			\ }
function! s:kind.action_table.a_p4_user_change.func(candidates) "{{{
	let candidate = a:candidates
	let user = s:get_UserName_from_users(candidate)
	let outs = perforce#set#PFUSER(user)
	call perforce#LogFile(outs)
endfunction
"}}}

call unite#define_kind(s:kind)

let &cpo = s:save_cpo
unlet s:save_cpo

