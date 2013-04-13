let s:save_cpo = &cpo
set cpo&vim


function! unite#kinds#k_p4#define()
	return s:kind
endfunction

let s:kind = { 'name' : 'k_p4',
			\ 'default_action' : 'a_add_fix',
			\ 'action_table' : {},
			\ }

let s:kind.action_table.a_add_fix = {
			\ 'description' : 'add qfix ( p4 )',
			\ 'is_selectable' : 1 ,
			\ }
function! s:kind.action_table.a_add_fix.func(candidates) "{{{

	" èâä˙âª
	cexpr ''	

	for candidate in a:candidates
		let depot = candidate.action__depot
		let path  = perforce#get_path_from_depot(depot)

		caddexpr path.':1:1'
	endfor

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

