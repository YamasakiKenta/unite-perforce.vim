let s:_file  = expand("<sfile>")
let s:_vital = vital#of('ymknjugg')
let s:_debug = s:_vital.import("Debug")
"exe s:_debug.exe_line()
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
			\ 'default_action' : 'a_4_user_change',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_user_change = {
			\ 'description' : 'ƒ†[ƒU[‚ÌØ‚è‘Ö‚¦',
			\ }
function! s:kind.action_table.a_p4_user_change.func(candidates) "{{{
	let candidate = a:candidates
	let user = candidate.action__user
	call system('p4 set P4User='.user)
	exe s:_debug.exe_line()
endfunction "}}}
