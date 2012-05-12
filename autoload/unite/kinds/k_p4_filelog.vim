function! unite#kinds#k_p4_filelog#define()
	return s:kind
endfunction

" ********************************************************************************
" kind - k_p4_filelog
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_filelog',
			\ 'default_action' : 'a_p4_print',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_print = {
			\ 'is_selectable' : 1, 
			\ }
function! s:kind.action_table.a_p4_print.func(candidates) "{{{
	for l:candidate in deepcopy(a:candidates)
		let name    = candidate.action__depot
		let revnum  = candidate.action__revnum

		" Vim ���ƁA# ����ꂽ��p�X���\�������ׁA���E�������K�v 
		call perforce#LogFile1(fnamemodify(name,':t').'\#'.revnum, 0) 
		let @b = name
		let strs = perforce#cmds('print -q '.perforce#Get_kk(name."#".revnum))

		" �f�[�^�̏o��
		call append(0,strs) 

	endfor
endfunction "}}}
