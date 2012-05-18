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
			\ 'is_selectable' : 1, 
			\ 'description' : '”äŠr‚·‚é', 
			\ }
function! s:kind.action_table.a_merge.func(candidates) "{{{
	for candidate in deepcopy(a:candidates)

		let defoult_cmd = perforce#get_pf_settings('diff_tool', 'common')[0]

		" ”äŠr‚·‚é–¼‘O‚ÌŽæ“¾
		let file1 = candidate.action__file1
		let file2 = candidate.action__file2

		call system('p4 edit '.perforce#Get_kk(file2))
		if defoult_cmd =~ 'kdiff3'
			call system(defoult_cmd.' '.perforce#Get_kk(file1).' '.perforce#Get_kk(file2),' -o ',perforce#Get_kk(file2))
		else
			call system(defoult_cmd.' '.perforce#Get_kk(file1).' '.perforce#Get_kk(file2))
		endif
	endfor

endfunction "}}}

let s:kind.action_table.a_copy = {
			\ 'is_selectable' : 1, 
			\ 'description' : '’u‚«Š·‚¦‚é', 
			\ }
function! s:kind.action_table.a_copy.func(candidates) "{{{
	for candidate in deepcopy(a:candidates)

		" ”äŠr‚·‚é–¼‘O‚ÌŽæ“¾
		let file1 = candidate.action__file1
		let file2 = candidate.action__file2

		call system('p4 edit '.perforce#Get_kk(file2))
		call system('copy '.perforce#Get_kk(file1).' '.perforce#Get_kk(file2))
	endfor

endfunction "}}}

