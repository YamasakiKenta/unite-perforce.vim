function! unite#kinds#k_p4#define()
	return s:kind
endfunction

let s:kind = { 'name' : 'k_p4',
			\ 'default_action' : 'a_pf_settings',
			\ 'action_table' : {},
			\ }

let s:kind.action_table.a_pf_settings = {
			\ 'description' : 'İ’è',
			\ }
function! s:kind.action_table.a_pf_settings.func(candidate) "{{{

	let source = a:candidate.source

	" İ’è‰æ–Ê‚ğ•\¦‚·‚é
	call unite#start_temporary([['p4_settings', source]])
endfunction "}}}
