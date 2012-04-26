function! unite#kinds#k_p4_clientMove#define()
	return s:kind
endfunction

"p4 k_clientMove
let s:kind = { 'name' : 'k_p4_clientMove',
			\ 'default_action' : 'a_merge',
			\ 'action_table' : {},
			\ }
call unite#define_kind(s:kind)

let s:kind.action_table.a_merge = {
			\ 'is_selectable' : 1, 
			\ 'description' : 'クライアントの変更', 
			\ }
function! s:kind.action_table.a_merge.func(candidates) "{{{
	for candidate in deepcopy(a:candidates)

		" 比較する名前の取得
		let file1 = candidate.action__file1
		let file2 = candidate.action__file2

		call system('p4 edit '.okazu#Get_kk(file2))
		call system(g:defoult_cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
	endfor

	unlet g:defoult_cmd

endfunction "}}}
