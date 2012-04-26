" ********************************************************************************
" depot�ő���ł������
" 
" ********************************************************************************
"
"
function! unite#kinds#k_depot#define()
	return s:kind
endfunction

function! s:setPfcmd(kind,cmd,des) "{{{
	" ********************************************************************************
	" �t�@�C������n�������̃R�}���h�̃A�N�V�����쐬
	" @param[in]	kind		unite kind	
	" @param[in]	cmd			p4 �R�}���h
	" @param[in]	des			������
	" ********************************************************************************
	"
	let action = {
				\ 'is_selectable' : 1, 
				\ 'description' : a:des,
				\ }

	" Unite�ɃA�N�V�����̒ǉ�
	call unite#custom_action(a:kind, 'a_p4_'.a:cmd, action)

	" �A�N�V�����p�X
	let kind = {
				\ 'k_depot' : 'depot'
				\ }

	" �������R�}���h�ɂ��� "{{{
	execute "
				\ function! action.func(candidates) \n
				\ 	let outs = [] \n
				\ 	for l:candidate in a:candidates \n
				\		let outs += perforce#cmds('".a:cmd." '.okazu#Get_kk(l:candidate.action__".
				\			get(kind,a:kind,"file").")) \n
				\ 	endfor \n
				\ 	call perforce#LogFile(outs) \n
				\ endfunction "
	"}}}
	unlet action
endfunction "}}}
call <SID>setPfcmd('file','add','�ǉ�')
call <SID>setPfcmd('file','edit','�ҏW')
call <SID>setPfcmd('k_depot','edit','�ҏW')
call <SID>setPfcmd('k_depot','delete','�폜')
call <SID>setPfcmd('k_depot','revert -a','���ɖ߂�')
call <SID>setPfcmd('k_depot','revert','���ɖ߂� ( ���� )')

"p4 k_depot 
let s:kind = { 'name' : 'k_depot',
			\ 'default_action' : 'a_open',
			\ 'action_table' : {},
			\ 'parents' : [],
			\ }
call unite#define_kind(s:kind)

let s:kind.action_table.a_open = {
			\ 'is_selectable' : 1,
			\ 'description' : '�J��',
			\ }
function! s:kind.action_table.a_open.func(candidates) "{{{
	for candidate in a:candidates
		let depot = candidate.action__depot

		" ���[�J���p�X���擾���ĊJ��
		let path = perforce#get_path_from_depot(depot)

		if  path =~ "file(s) not on client."
			" �t�@�C���̌���
			echo 'FIND...'
			let file = fnamemodify(depot,':t')
			exe 'find' $PFCLIENTPATH.'/**/'.file
		else 
			exe 'edit' path
		endif 

	endfor
endfunction "}}}

let s:kind.action_table.a_p4_files = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̏��',
			\ }
function! s:kind.action_table.a_p4_files.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('files '.join(depots))
	call okazu#LogFile('p4_files')
	call append(0,outs)
endfunction "}}}

let s:kind.action_table.a_p4_move = {
			\ 'is_selectable' : 1 ,
			\ 'description' : '�ړ� ( ���O�̕ύX )' ,
			\ }
function! s:do_move(oris,file) "{{{
	"********************************************************************************
	" perforce�Ńt�@�C������ύX����֐�
	" @param[in]	oris	�ύX�O�̖��O
	" @param[in]	file	�ύX��̖��O���ۑ�����Ă���t�@�C����
	"********************************************************************************

	"let g:debug = oris
	"let g:debug = oris + ['debug']


	let trans = readfile(a:file) " # �ύX��̖��O�̎擾

	let i = 0     " # ���[�v����ϐ�
	let outs = [] " # ���O�t�@�C���p�ϐ�

	for ori in a:oris
		let tran = trans[i]
		let dir = fnamemodify(ori,':h').'/'                               " # �f�B���N�g���̎擾
		let outs += perforce#cmds('edit '.okazu#Get_kk(ori))                      " # �ҏW�\�ɂ���
		let outs += perforce#cmds('move '.okazu#Get_kk(ori).' '.okazu#Get_kk(dir.tran)) " # ������ - ���O�̕ύX
		let i += 1

	endfor

	" # ���O�t�@�C���̏o��
	call perforce#LogFile(outs)

endfunction "}}}
function! s:kind.action_table.a_p4_move.func(candidates) "{{{
	" ********************************************************************************
	" perforce�Ŗ��O�̕ύX���s��
	" �ꎞ�t�@�C�����ۑ����ꂽ��A�l���X�V����
	" @param[in]	g:pfmove_oris		���̖��O ( ���[�J���p�X )
	" @param[in]	g:pfmove_tmpfile	�ύX��̖��O���ۑ������
	" ********************************************************************************
	"
	" �I�����Ă�����̂�����΁A 
	"if len(a:candidates) == 1 
	if 0
		" ������̏ꍇ "{{{
		let l:candidate  = a:candidates[0]
		let depot        = l:candidate.action__depot
		let path         = perforce#get_path_from_depot(depot)
		let file         = fnamemodify(path,":t")
		let dir          = fnamemodify(path,":h")
		let new          = input(file.' -> ')
		if new != ''
			let outs = []
			let outs += perforce#cmds('edit '.path)
			let outs += perforce#cmds('move '.path.' '.dir.'/'.new)
			call perforce#LogFile(outs)
		endif
		"}}}
	else 
		" �����I���̏ꍇ "{{{

		let g:pfmove_tmpfile = copy(g:pf_tmpfile)
		"
		" ���̃p�X�̓o�^�Ə����̃t�@�C�����̎擾 "{{{
		let names = []
		let g:pfmove_oris = []

		for candidate in a:candidates
			let depot          = candidate.action__depot
			let path           = perforce#get_path_from_depot(depot)
			let g:pfmove_oris += [path]
			let names         += [substitute(fnamemodify(path,":t"),'\n','','')] " # �t�@�C�����̂ݎ擾
		endfor
		"}}}
		"
		" �����̖��O�̏����o��
		call okazu#event_save_file(g:pfmove_tmpfile,names,'perforce#do_move(g:pfmove_oris, g:pfmove_tmpfile)')

		"}}}
	endif 


endfunction "}}}

let s:kind.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '����',
			\ }
function! s:kind.action_table.a_p4_diff.func(candidates) "{{{
	let args = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(args,'p4_diff')]) 
endfunction "}}}

let s:kind.action_table.a_p4_diff_tool = {
			\ 'is_selectable' : 1 ,  
			\ 'description' : '���� ( TOOL )' ,
			\ }
function! s:kind.action_table.a_p4_diff_tool.func(candidates) "{{{
	for l:candidate in a:candidates
		let depot = l:candidate.action__depot
		call perforce#pfDiff(depot)
	endfor
endfunction "}}}

let s:kind.action_table.a_p4_reopen = {
			\ 'is_selectable' : 1 ,
			\ 'description' : '�`�F���W���X�g�̕ύX' ,
			\ }
function! s:kind.action_table.a_p4_reopen.func(candidates) "{{{
	let g:reopen_depots= [] " # ������
	for l:candidate in a:candidates
		call add(g:reopen_depots, l:candidate.action__depot) " # �ۑ�
	endfor

	" �ύX������߂�
	Unite p4_changes_pending -default-action=a_p4_change_reopen
	"call unite#start([['p4_changes_pending']]) " # default�A�N�V�����̐ݒ���@���킩��Ȃ�
endfunction "}}}

let s:kind.action_table.a_p4_filelog = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '����',
			\ }
function! s:kind.action_table.a_p4_filelog.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(depots, 'p4_filelog')])
endfunction "}}}

let s:kind.action_table.a_p4_sync = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̍ŐV����',
			\ }
function! s:kind.action_table.a_p4_sync.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('sync '.join(depots))
	call perforce#LogFile(outs)
endfunction "}}}
