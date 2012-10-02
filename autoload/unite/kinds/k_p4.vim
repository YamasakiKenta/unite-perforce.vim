function! unite#kinds#k_p4#define()
	return s:kind
endfunction

let s:kind = { 'name' : 'k_p4',
			\ 'default_action' : 'a_pf_settings',
			\ 'action_table' : {},
			\ }

let s:kind.action_table.a_pf_settings = {
			\ 'description' : '設定',
			\ }
function! s:kind.action_table.a_pf_settings.func(candidate) "{{{

	" 設定画面を表示する
	call unite#start_temporary([['p4_settings', a:candidate.source]])
endfunction "}}}

let s:kind.action_table.a_add_fix = {
			\ 'description' : 'quickfixに追加',
			\ 'is_selectable' : 1 ,
			\ }
function! s:kind.action_table.a_add_fix.func(candidates) "{{{

	" 初期化
	cexpr ''	

	for candidate in a:candidates
		let depot = candidate.action__depot
		let path = perforce#get_path_from_depot(depot)

		" 追加する
		caddexpr path.':1:1'
	endfor

endfunction "}}}
