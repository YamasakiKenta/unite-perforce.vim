let s:save_cpo = &cpo
set cpo&vim


function! unite#kinds#k_p4_help#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_help
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_help',
			\ 'default_action' : 'a_help',
			\ 'action_table' : {},
			\ 'parents' : [],
			\ }

let s:kind.action_table.a_help = {
			\ 'description' : 'Ú‚µ‚¢î•ñ‚ğ•\¦',
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.a_help.func(candidates) "{{{
	let outs = []
	for candidate in a:candidates
		let str = candidate.action__cmd
		let outs += split(system('p4 help '.str), "\n")
	endfor

	call perforce_2#show_outs(outs)
endfunction 
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

