let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_change#define()
	return [ 
				\ s:kind_k_p4_change_pending,
				\ s:kind_k_p4_change_reopen,
				\ ]
endfunction

" ********************************************************************************
" kind - k_p4_change_reopen
" ********************************************************************************
let s:kind_k_p4_change_reopen = {
			\ 'name' : 'k_p4_change_reopen',
			\ 'default_action' : 'a_p4_change_reopen',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind_k_p4_change_reopen.action_table.a_p4_change_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX ( reopen )' ,
			\ } 
function! s:kind_k_p4_change_reopen.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕ύX
	" action ������s�����ꍇ�́A�I�������t�@�C����ύX����B
	" source ������s�����ꍇ�́A�J�����t�@�C����ύX����B
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots
	let client        = a:candidate.action__client

	"�`�F���W���X�g�̔ԍ��̎擾
	let chnum = s:make_new_changes(a:candidate)

	" �`�F���W���X�g�̕ύX
	let cmd = 'p4  '.client.' reopen -c '.chnum.' "'.join(reopen_depots,'" "').'"'
	call unite#print_message(cmd)
	let outs = split(system(cmd), "\n")

	" ���O�̏o��
	call perforce#LogFile(outs)

endfunction
"}}}

" ********************************************************************************
" kind - k_p4_change_pending
" ********************************************************************************
let s:kind_k_p4_change_pending = { 
			\ 'name' : 'k_p4_change_pending',
			\ 'default_action' : 'a_p4_change_opened',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

" ����
let s:kind_k_p4_change_pending.action_table.delete = {
			\ 'description' : '�`�F���W���X�g�̍폜' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_k_p4_change_pending.action_table.delete.func(candidates) "{{{
	let i = 1
	for l:candidate in a:candidates
		let num    = l:candidate.action__chnum
		let client = l:candidate.action__client
		let out    = system('p4 '.client.' change -d '.num)
		let outs   = split(out,'\n')
		call perforce#LogFile(outs)
		let i += len(outs)
	endfor
endfunction
"}}}

"�����I���\
let s:kind_k_p4_change_pending.action_table.a_p4_change_opened = { 
			\ 'description' : '�t�@�C���̕\��',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_opened.func(candidates) "{{{

	let data_ds = []
	for candidate in a:candidates
		" �`�F���W���X�g�̔ԍ��̎擾������
		let data_d= {
					\ 'chnum'  : s:make_new_changes(candidate),
					\ 'client' : candidate.action__client,
					\ }
		call add(data_ds, data_d)
	endfor

	" echo data_d

	echo 's:kind_k_p4_change_pending.action_table.a_p4_change_opened.func - ' string(data_ds)

	call unite#start_temporary([insert(data_ds, 'p4_opened')]) " # ���Ȃ� ? 
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_info = { 
			\ 'description' : '�`�F���W���X�g�̏��' ,
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_info.func(candidates) "{{{
	let outs = []
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		let outs += split(system('P4 change -o '.chnum),'\n')
	endfor
	call perforce#LogFile(outs)
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_submit = {
			\ 'description' : '�T�u�~�b�g' ,
			\ 'is_selectable' : 1,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_change_submit.func(candidates) "{{{

	if perforce#data#get('g:unite_perforce_is_submit_flg') == 0
		call perforce_2#echo_error('safe mode.')
		call input("Push Any Keys...") 
	else
		let chnums = map(copy(a:candidates), "v:val.action__chnum")
		let tmp_ds = perforce#cmd#new('submit','',' -c '.join(chnums))
		let outs = []
		for tmp_d in tmp_ds
			call add(outs, tmp_d.cmd)
			call extend(outs, tmp_d.outs)
		endfor

		call perforce_2#common_action_out(outs)
	endif 

endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4change_describe = { 
			\ 'description' : '�����̕\��',
			\ 'is_selectable' : 1, 
			\ 'is_quit' : 0,
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4change_describe.func(candidates) "{{{
	let chnums = map(copy(a:candidates),"v:val.action__chnum")
 	call unite#start_temporary([insert(chnums,'p4_describe')])
endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_matomeDiff = { 
			\ 'description' : '�����̂܂Ƃ߂�\��',
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_k_p4_change_pending.action_table.a_p4_matomeDiff.func(candidates) "{{{
	for l:candidate in a:candidates
		let chnum = l:candidate.action__chnum
		call perforce#matomeDiffs(chnum)
	endfor
endfunction
"}}}
"
let s:kind_k_p4_change_pending.action_table.a_p4_change_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX' ,
			\ } 
function! s:kind_k_p4_change_pending.action_table.a_p4_change_reopen.func(candidate) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕ύX
	" action ������s�����ꍇ�́A�I�������t�@�C����ύX����B
	" source ������s�����ꍇ�́A�J�����t�@�C����ύX����B
	" ********************************************************************************

	let reopen_depots = a:candidate.action__depots

	"�`�F���W���X�g�̔ԍ��̎擾
	let chnum = s:make_new_changes(a:candidate)

	" �`�F���W���X�g�̕ύX
	let outs = perforce#cmd#base('reopen','',' -c '.chnum.' '.perforce#get_kk(join(reopen_depots,'" "'))).outs

	" ���O�̏o��
	call perforce#LogFile(outs)

endfunction
"}}}

let s:kind_k_p4_change_pending.action_table.a_p4_change_rename = {
			\  'description' : '���O�̕ύX' ,
			\ }
function! s:get_chname_from_change(str) "{{{
	let str = a:str
	let str = substitute(str, '.\{-}''', '', '')
	let str = substitute(str, '''$', '', '')
	return str
endfunction
"}}}
function! s:kind_k_p4_change_pending.action_table.a_p4_change_rename.func(candidate) "{{{
	let chnum = a:candidate.action__chnum
	let chname = s:get_chname_from_change(a:candidate.word)
	let chname = input(chname.'-> ', chname)

	" ���͂��Ȃ��ꍇ�́A���s���Ȃ�
	if chname =~ ""
		let outs = s:pfChange(chname,chnum)
		call perforce#LogFile(outs)
	endif
endfunction
"}}}

if 1
	call unite#define_kind(s:kind_k_p4_change_pending)
	call unite#define_kind(s:kind_k_p4_change_reopen)
endif

"=== SUB ===
function! s:pfChange(str,...) "{{{
	"********************************************************************************
	" �`�F���W���X�g�̍쐬
	" @param[in]	str		�`�F���W���X�g�̃R�����g
	" @param[in]	...		�ҏW����`�F���W���X�g�ԍ�
	"********************************************************************************
	"
	"�`�F���W�ԍ��̃Z�b�g ( ���������邩 )
	let chnum     = get(a:,'1','')

	"ChangeList�̐ݒ�f�[�^���ꎞ�ۑ�����
	let tmp = system('p4 change -o '.chnum)                          

	"�R�����g�̕ҏW
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" �V�K�쐬�̏ꍇ�́A�t�@�C�����܂܂Ȃ�
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"�ꎞ�t�@�C���̏����o��
	call writefile(split(tmp,'\n'),perforce#get_tmp_file())

	" �`�F���W���X�g�̍쐬
	" �� client �ɑΉ�����
	let out = split(system('more '.perforce#get_kk(perforce#get_tmp_file()).' | p4 '.a:client.'change -i', '\n'))

	return out

endfunction
"}}}
function! s:make_new_changes(candidate) "{{{
" ********************************************************************************
" �`�F���W���X�g�̔ԍ��̎擾������ ( new �̏ꍇ�́A�V�K�쐬 )
" @param[in]	candidate	unite �̂���	
" @retval       chnum		�ԍ�
" ********************************************************************************

	let chnum = a:candidate.action__chnum

	if chnum == 'new'
		let chname = a:candidate.action__chname

		" �`�F���W���X�g�̍쐬
		let outs = s:pfChange(chname)

		"�`�F���W���X�g�̐V�K�쐬�̌��ʂ���ԍ����擾����
		let chnum = outs[1]
	endif

	return chnum
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

