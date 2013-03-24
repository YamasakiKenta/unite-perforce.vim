let s:save_cpo = &cpo
set cpo&vim
setl enc=utf8

let s:_file  = expand("<sfile>")


let s:_debug = vital#of('unite-perforce.vim').import("Mind.Debug")
"
function! unite#kinds#k_p4_clients#define()
	return s:kind
endfunction
function! unite#kinds#k_p4_users#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_users
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_users',
			\ 'default_action' : 'a_p4_user_change',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_user_change = {
			\ 'description' : 'ユーザーの切り替え',
			\ }
function! s:kind.action_table.a_p4_user_change.func(candidates) "{{{
	let candidate = a:candidates
	let user = candidate.action__user
	let outs = perforce#set_PFUSER(user)
	call perforce#LogFile(outs)
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

