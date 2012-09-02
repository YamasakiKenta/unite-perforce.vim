"vim : set fdm = marker :
function! unite#kinds#k_p4_change#define()
	return [ s:kind_k_p4_change, s:kind_k_p4_change_reopen ]
endfunction

" ********************************************************************************
" kind - k_p4_change_reopen
" ********************************************************************************
let s:kind = {
			\ 'name' : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_p4_change_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX ( reopen )' ,
			\ } 
function! s:kind.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕ύX
	" action ������s�����ꍇ�́A�I�������t�@�C����ύX����B
	" source ������s�����ꍇ�́A�J�����t�@�C����ύX����B
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots

	"�`�F���W���X�g�̔ԍ��̎擾
	let chnum = <SID>make_new_changes(a:candidate)

	" �`�F���W���X�g�̕ύX
	let outs = perforce#pfcmds('reopen','',' -c '.chnum.' '.common#Get_kk(join(reopen_depots,'" "')))

	" ���O�̏o��
	call perforce#LogFile(outs)

endfunction "}}}

let s:kind_k_p4_change_reopen = s:kind
unlet s:kind

" ********************************************************************************
" kind - k_p4_change
" ********************************************************************************
let s:kind = { 'name' : 'k_p4_change',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

" ����
let s:kind.action_table.delete = {
			\ 'description' : '�`�F���W���X�g�̍폜' ,
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num = l:candidate.action__chnum
		let out = system('p4 change -d '.num)
		let outs = split(out,'\n')
		call perforce#LogFile(outs)
		let i += len(outs)
	endfor
endfunction "}}}

"�����I���\
let s:kind.action_table.a_p4_change_opened = { 
			\ 'description' : '�t�@�C���̕\��',
			\ 'is_selectable' : 1, 
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
			\ 'description' : '�`�F���W���X�g�̏��' ,
			\ 'is_selectable' : 1, 
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

let s:kind.action_table.a_p4_change_submit = {
			\ 'description' : '�T�u�~�b�g' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.a_p4_change_submit.func(candidates) "{{{

	if g:pf_settings.is_submit_flg.common == 0
		echo ' g:pf_settings.is_submit_flg.common is not TRUE'
		return 
	else

		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let outs = perforce#pfcmds('submit','',' -c '.join(chnums))
		call perforce#LogFile(outs)
	endif 

endfunction "}}}

let s:kind.action_table.a_p4change_describe = { 
			\ 'description' : '�����̕\��',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
	call unite#start([insert(chnums,'p4_describe')])
endfunction "}}}

let s:kind.action_table.a_p4_matomeDiff = { 
			\ 'description' : '�����̂܂Ƃ߂�\��',
			\ 'is_selectable' : 1, 
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
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots

	"�`�F���W���X�g�̔ԍ��̎擾
	let chnum = <SID>make_new_changes(a:candidate)

	" �`�F���W���X�g�̕ύX
	let outs = perforce#pfcmds('reopen','',' -c '.chnum.' '.common#Get_kk(join(reopen_depots,'" "')))

	" ���O�̏o��
	call perforce#LogFile(outs)

endfunction "}}}

let s:kind.action_table.a_p4_change_rename = {
			\  'description' : '���O�̕ύX' ,
			\ 'is_quit' : 0,
			\ }
function! s:get_chname_from_change(str) "{{{
	let str = a:str
	let str = substitute(str, '.\{-}''', '', '')
	let str = substitute(str, '''$', '', '')
	return str
endfunction "}}}
function! s:kind.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	let chname = <SID>get_chname_from_change(a:candidate.word)
	let chname = input(chname.'-> ', chname)

	" ���͂��Ȃ��ꍇ�́A���s���Ȃ�
	if chname =~ ""
		let outs = perforce#pfChange(chname,chnum)
		call perforce#LogFile(outs)
	endif
endfunction "}}}

let s:kind_k_p4_change = s:kind
unlet s:kind

" ********************************************************************************
" �`�F���W���X�g�̔ԍ��̎擾������ ( new �̏ꍇ�́A�V�K�쐬 )
" @param[in]	candidate	unite �̂���	
" @retval       chnum		�ԍ�
" ********************************************************************************
function! <SID>make_new_changes(candidate) "{{{

	let chnum = a:candidate.action__chnum
	let chname = a:candidate.action__chname

	if chnum == 'new'
		" �`�F���W���X�g�̍쐬
		let outs = perforce#pfChange(chname)

		"�`�F���W���X�g�̐V�K�쐬�̌��ʂ���ԍ����擾����
		let chnum = perforce#get_ChangeNum_from_changes(outs[0])
	endif

	return chnum
endfunction "}}}

