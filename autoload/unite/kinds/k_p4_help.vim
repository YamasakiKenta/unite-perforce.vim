let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_help#define()
	return s:kind_help
endfunction

function! s:get_pfcmd_from_help(candidate) "{{{
	return matchstr(a:candidate.action__out, '\t\zs\w\+\ze ')
endfunction
"}}}

let s:kind_help = { 
			\ 'name' : 'k_p4_help',
			\ 'default_action' : 'a_help',
			\ 'action_table' : {},
			\ 'parents' : [],
			\ }

let s:kind_help.action_table.a_help = {
			\ 'description' : 'help',
			\ 'is_selectable' : 1,
			\ }
function! s:kind_help.action_table.a_help.func(candidates) "{{{
	" [2013-06-07 07:56]
	let outs = []
	for candidate in a:candidates
		let cmd = s:get_pfcmd_from_help( candidate ) 
		let outs += split(perforce#system('p4 help '.cmd), "\n")
	endfor

	call perforce#show(outs)
endfunction 
"}}}

call unite#define_kind(s:kind_help)

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
