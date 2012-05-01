"vim : set fdm = marker :
function! unite#kinds#k_p4_change#define()
	return [ s:k_p4_change, s:k_p4_change_reopen ]
endfunction

" ********************************************************************************
let s:kind = { 'name' : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table' : {},
			\ }

" --------------------------------------------------------------------------------

let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX' ,
			\ 'is_quit' : 0,
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕ύX
	" action ������s�����ꍇ�́A�I�������t�@�C����ύX����B
	" source ������s�����ꍇ�́A�J�����t�@�C����ύX����B
	"
	" @param[in]	g:reopen_depots		�I�������t�@�C��
	" ********************************************************************************

	" �I�������t�@�C�����Ȃ��ꍇ�́A���݂̃t�@�C�����g�p����
	if !len(g:reopen_depots)
		let g:reopen_depots = a:candidate.action__path
	endif

	"�`�F���W���X�g�̔ԍ��̎擾
	let chnum = <SID>make_new_changes(a:candidate)

	" �`�F���W���X�g�̕ύX
	let outs = perforce#cmds('reopen -c '.chnum.' '.okazu#Get_kk(join(g:reopen_depots,'" "')))

	" �ǉ�����t�@�C����������������
	let g:reopen_depots = [] 

	" ���O�̏o��
	call perforce#LogFile(outs)

endfunction "}}}

let s:k_p4_change_reopen = s:kind
unlet s:kind
" ********************************************************************************
let s:kind = { 'name' : 'k_p4_change',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ }
" --------------------------------------------------------------------------------
"�����I���\
let s:kind.action_table.a_p4_change_opened = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̕\��',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_opened.func(candidates) "{{{

	let chnums = []
	for candidate in a:candidates
		" �`�F���W���X�g�̔ԍ��̎擾������
		let chnums += [<SID>make_new_changes(candidate)]
	endfor

	call unite#start_temporary([insert(chnums,'p4_opened')]) " # ���Ȃ� ? 
endfunction "}}}

let s:kind.action_table.a_p4_change_info = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�`�F���W���X�g�̏��' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#LogFile(outs)
endfunction "}}}

let s:kind.action_table.a_p4_change_delete = {
			\ 'is_selectable' : 1,
			\ 'description' : '�`�F���W���X�g�̍폜' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num = l:candidate.action__chnum
		let out = system('p4 change -d '.num)
		let outs = split(out,'\n')
		call perforce#LogFile(outs)
		let i += len(outs)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_change_submit = {
			\ 'is_selectable' : 1,
			\ 'description' : '�T�u�~�b�g' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_submit.func(candidates) "{{{

	if g:pf_setting.bool.is_submit_flg.value.common == 0
		echo ' g:pf_setting.bool.is_submit_flg.value.common is not TRUE'
		return 
	else

		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let outs = perforce#cmds('submit -c '.join(chnums))
		call perforce#LogFile(outs)
	endif 

endfunction "}}}

let s:kind.action_table.a_p4change_describe = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�����̕\��',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
	call unite#start([insert(chnums,'p4_describe')])
endfunction "}}}

let s:kind.action_table.a_p4_matomeDiff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�����̂܂Ƃ߂�\��',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		call perforce#matomeDiffs(chnum)
	endfor
endfunction "}}}
"
let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX' ,
			\ 'is_quit' : 0,
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕ύX
	" action ������s�����ꍇ�́A�I�������t�@�C����ύX����B
	" source ������s�����ꍇ�́A�J�����t�@�C����ύX����B
	"
	" @param[in]	g:reopen_depots		�I�������t�@�C��
	" ********************************************************************************

	" �I�������t�@�C�����Ȃ��ꍇ�́A���݂̃t�@�C�����g�p����
	if !len(g:reopen_depots)
		let g:reopen_depots = a:candidate.action__path
	endif

	"�`�F���W���X�g�̔ԍ��̎擾
	let chnum = <SID>make_new_changes(a:candidate)

	" �`�F���W���X�g�̕ύX
	let outs = perforce#cmds('reopen -c '.chnum.' '.okazu#Get_kk(join(g:reopen_depots,'" "')))

	" �ǉ�����t�@�C����������������
	let g:reopen_depots = [] 

	" ���O�̏o��
	call perforce#LogFile(outs)

endfunction "}}}

let s:kind.action_table.a_p4_change_rename = {
			\  'description' : '���O�̕ύX' ,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	"let chname = input('ChangeList Comment (change): '.a:candidate.action__chname, a:candidate.action__chname)
	let chname = input('ChangeList Comment (change): ')

	" ���͂��Ȃ��ꍇ�́A���s���Ȃ�
	if chname =~ ""
		let outs = perforce#pfChange(chname,chnum)
		call perforce#LogFile(outs)
	endif
endfunction "}}}

let s:k_p4_change = s:kind
unlet s:kind

" ********************************************************************************
" �`�F���W���X�g�̔ԍ��̎擾������ ( new �̏ꍇ�́A�V�K�쐬 )
" @param[in]	candidate	unite �̂���	
" @retval       chnum		�ԍ�
" ********************************************************************************
function! s:make_new_changes(candidate) "{{{

	let chnum = a:candidate.action__chnum
	let chname = a:candidate.action__chname

	if chnum == 'new'
		" �`�F���W���X�g�̍쐬
		let outs = perforce#pfChange(chname)

		"�`�F���W���X�g�̐V�K�쐬�̌��ʂ���ԍ����擾����
		let chnum = perforce#get_ChangeNum_from_changes(outs[0])
	else
		let chnum = chnum
	endif

	return chnum
endfunction "}}}

