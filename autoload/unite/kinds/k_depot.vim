" ********************************************************************************
" depot�ő���ł������
" ********************************************************************************
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
				\		let outs += perforce#cmds('".a:cmd." '.perforce#Get_kk(l:candidate.action__".
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
			\ 'parents' : ['k_p4'],
			\ }
call unite#define_kind(s:kind)

function! s:find_filepath_from_depot(candidate) "{{{
	" ********************************************************************************
	" �ҏW����t�@�C�������擾���� 
	" @param[in]	candidate		unite action �̈���
	" @retval       path			�ҏW����t�@�C����
	" ********************************************************************************
	let candidate = a:candidate
	let depot = candidate.action__depot

	" ���[�J���p�X���擾���ĊJ��
	let path = perforce#get_path_from_depot(depot)

	" �t�@�C����������Ȃ������ꍇ�́A�T��
	if  path =~ "file(s) not on client."
		" �t�@�C���̌���
		echo 'FIND...'
		let file = fnamemodify(depot,':t')
		exe 'find' $PFCLIENTPATH.'/**/'.file
		let paths = glob($PFCLIENTPATH.'/**/'.file)
		let path = paths[0]
	endif 
	return path
endfunction "}}}

let s:kind.action_table.a_open = {
			\ 'description' : '�J��',
			\ }
function! s:kind.action_table.a_open.func(candidate) "{{{
	let path = <SID>find_filepath_from_depot(a:candidate) 
	exe 'edit' path
endfunction "}}}

let s:kind.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0, 
			\ }
function! s:kind.action_table.preview.func(candidate) "{{{
	let path = <SID>find_filepath_from_depot(a:candidate) 
	exe 'pedit' path
endfunction "}}}

let s:kind.action_table.a_p4_files = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̏��',
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_files.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('files '.join(depots))
	call perforce#LogFile1('p4_files', 0)
	call append(0,outs)
endfunction "}}}

let s:kind.action_table.a_p4_move = {
			\ 'is_selectable' : 1 ,
			\ 'description' : '�ړ� ( ���O�̕ύX )' ,
			\ 'is_quit' : 0 ,
			\ }
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

		let g:pfmove_tmpfile = copy($PFTMP)
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
		call perforce#event_save_file(g:pfmove_tmpfile,names,'perforce#do_move(g:pfmove_oris, g:pfmove_tmpfile)')

		"}}}
	endif 


endfunction "}}}

let s:kind.action_table.delete = { 
			\ 'description' : '����',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.delete.func(candidate) "{{{
	"let wnum = winnr()
	let depot = a:candidate.action__depot

	call perforce#LogFile1('diff', 1, perforce#cmds('diff '.depot))

	wincmd p
endfunction "}}}

let s:kind.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '����',
			\ }
function! s:kind.action_table.a_p4_diff.func(candidates) "{{{
	let args = map(copy(a:candidates),"v:val.action__depot")
	call unite#start_temporary([insert(args,'p4_diff')]) 
endfunction "}}}

let s:kind.action_table.a_p4_diff_tool = {
			\ 'is_selectable' : 1 ,  
			\ 'description' : '���� ( TOOL )' ,
			\ 'is_quit' : 0 ,
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
	call unite#start_temporary(['p4_changes_pending_reopen'])
endfunction "}}}

let s:kind.action_table.a_p4_filelog = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '����',
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_filelog.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(depots, 'p4_filelog')])
endfunction "}}}

let s:kind.action_table.a_p4_sync = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̍ŐV����',
			\ 'is_quit' : 0 ,
			\ }
function! s:kind.action_table.a_p4_sync.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#cmds('sync '.join(depots))
	call perforce#LogFile(outs)
endfunction "}}}
