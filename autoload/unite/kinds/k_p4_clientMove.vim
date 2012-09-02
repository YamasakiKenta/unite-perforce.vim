function! unite#kinds#k_p4_clientMove#define()
	return s:kind
endfunction

"********************************************************************************
"kind k_clientMove
"********************************************************************************
let s:kind = { 'name' : 'k_p4_clientMove',
			\ 'default_action' : 'a_merge',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }
call unite#define_kind(s:kind)

let s:kind.action_table.a_merge = {
			\ 'description' : '��r����', 
			\ 'is_selectable' : 1, 
			\ }
function! s:kind.action_table.a_merge.func(candidates) "{{{
	for candidate in deepcopy(a:candidates)

		let defoult_cmd = perforce#setting#get('diff_tool', 'common').datas[0]

		" ��r���閼�O�̎擾
		let file1 = candidate.action__file1
		let file2 = candidate.action__file2

		call system('p4 edit '.common#Get_kk(file2))
		if defoult_cmd =~ 'kdiff3'
			call system(defoult_cmd.' '.common#Get_kk(file1).' '.common#Get_kk(file2),' -o ',common#Get_kk(file2))
		else
			call system(defoult_cmd.' '.common#Get_kk(file1).' '.common#Get_kk(file2))
		endif
	endfor

endfunction "}}}

let s:kind.action_table.a_copy = {
			\ 'description' : '�u��������', 
			\ 'is_selectable' : 1, 
			\ }
function! s:kind.action_table.a_copy.func(candidates) "{{{
	for candidate in deepcopy(a:candidates)

		" ��r���閼�O�̎擾
		let file1 = candidate.action__file1
		let file2 = candidate.action__file2

		call system('p4 edit '.common#Get_kk(file2))
		call system('copy '.common#Get_kk(file1).' '.common#Get_kk(file2))
	endfor

endfunction "}}}

