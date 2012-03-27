"vim : set fdm = marker :
function! unite#kinds#k_p4_change#define()
	return s:kind
endfunction

let s:kind = { 'name' : 'k_p4_change',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ }

"�����I���\
let s:kind.action_table.a_p4_change_opened = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̕\��',
			\ }
function! s:kind.action_table.a_p4_change_opened.func(candidates) "{{{

	" �`�F���W���X�g�̔ԍ��̎擾������
	let chnums = []
	for candidate in a:candidates
		let chnum = candidate.action__chnum
		let chname = candidate.action__chname

		if chnum =~ 'new'
			" �`�F���W���X�g�̍쐬
			let outs = perforce#pfChange(chname)

			"�`�F���W���X�g�̐V�K�쐬�̌��ʂ���ԍ����擾����
			let g:debug = outs
			let chnums += [perforce#get_ChangeNum_from_changes(outs[0])]

		else
			let chnums += [chnum]

		endif

	endfor

	call unite#start([insert(chnums,'p4_opened')])

endfunction "}}}

let s:kind.action_table.a_p4_change_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�`�F���W���X�g�̏��' 
			\ ,}
function! s:kind.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#pfLogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_change_delete = {
			\ 'is_selectable' : 1,
			\ 'description' : '�`�F���W���X�g�̍폜' 
			\ }
function! s:kind.action_table.a_p4_change_delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num = l:candidate.action__chnum
		let out = system('p4 change -d '.num)
		let outs = split(out,'\n')
		call perforce#pfLogFile(outs)
		let i += len(outs)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_change_submit = {
			\ 'is_selectable' : 1,
			\ 'description' : '�T�u�~�b�g' 
			\ }
function! s:kind.action_table.a_p4_change_submit.func(candidates) "{{{

	if g:pf_is_submit_flg == 0
		echo ' g:pf_is_submit_flg is not TRUE'
		return 
	else
		"let outs = []
		"for l:candidate in a:candidates
		"let chnum = l:candidate.action__chnum
		"let outs += perforce#cmds('submit -c '.chnum)
		"endfor
		"
		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let outs = perforce#cmds('submit -c '.join(chnums))
		call perforce#pfLogFile(outs)
	endif 

endfunction "}}}

let s:kind.action_table.a_p4change_describe = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�����̕\��',
			\ }
function! s:kind.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
	call unite#start([insert(chnums,'p4_describe')])
endfunction "}}}

let s:kind.action_table.a_p4_matomeDiff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�����̂܂Ƃ߂�\��',
			\ }
function! s:kind.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		call perforce#matomeDiffs(chnum)
	endfor
endfunction "}}}
"
"�ЂƂ̂ݑI���\
let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX' 
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidates) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕ύX
	" action ������s�����ꍇ�́A�I�������t�@�C����ύX����B
	" source ������s�����ꍇ�́A�J�����t�@�C����ύX����B
	"
	" @param[in]	g:reopen_depots		�I�������t�@�C��
	" ********************************************************************************
	let chnum = a:candidates.action__chnum

	" �I�������t�@�C�����Ȃ��ꍇ�́A���݂̃t�@�C�����g�p����
	if !len(g:reopen_depots)
		let g:reopen_depots = a:candidates.action__path
	endif

	" �`�F���W���X�g�̕ύX
	let outs = perforce#cmds('reopen -c '.chnum.' '.okazu#Get_kk(join(g:reopen_depots,'" "')))

	" Ignore
	let g:reopen_depots = [] 

	" ���O�̏o��
	call perforce#pfLogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_change_rename = {
			\  'description' : '���O�̕ύX' 
			\ }
function! s:kind.action_table.a_p4_change_rename.func(candidates) "{{{
	let num = a:candidates.action__chnum
	let str = input('ChangeList Comment (change): ')
	let outs = perforce#pfChange(str,num)
	call perforce#pfLogFile(outs)
endfunction "}}}
