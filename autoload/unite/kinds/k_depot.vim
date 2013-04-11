let s:save_cpo = &cpo
set cpo&vim

" ********************************************************************************
" depot�ő���ł������
" ********************************************************************************
function! unite#kinds#k_depot#define()
	return s:kind_depot
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
				\ let outs = [] \n
				\ for l:candidate in a:candidates \n
					\ let outs += perforce#pfcmds('". a:cmd ."','',perforce#common#get_kk(l:candidate.action__". get(kind,a:kind,"path") .")).outs \n
				\ endfor \n
				\ call perforce#LogFile(outs) \n
			\ endfunction 
			\ "
	"}}}
	unlet action
endfunction "}}}

call s:setPfcmd('jump_list' , 'add'       , '�ǉ�'               ) 
call s:setPfcmd('jump_list' , 'edit'      , '�ҏW'               ) 
call s:setPfcmd('file'      , 'add'       , '�ǉ�'               ) 
call s:setPfcmd('file'      , 'edit'      , '�ҏW'               ) 
call s:setPfcmd('k_depot'   , 'edit'      , '�ҏW'               ) 
call s:setPfcmd('k_depot'   , 'delete'    , '�폜'               ) 
call s:setPfcmd('k_depot'   , 'revert -a' , '���ɖ߂�'           ) 
call s:setPfcmd('k_depot'   , 'revert'    , '���ɖ߂� [ ���� ] ' ) 

function! s:find_filepath_from_depot(candidate) "{{{
	" ********************************************************************************
	" �ҏW����t�@�C�������擾���� 
	" @param[in]	candidate		unite action �̈���
	" @retval       path			�ҏW����t�@�C����
	" ********************************************************************************
	let depot     = a:candidate.action__depot
	if exists( 'a:candidate.action__client' )
		let client = a:candidate.action__client
		let path = perforce#get_path_from_depot_with_client(client, depot)
	else
		let path = perforce#get_path_from_depot(depot)
	endif

	return path
endfunction "}}}

"p4 k_depot 
let s:kind_depot = {
			\ 'name'           : 'k_depot',
			\ 'default_action' : 'a_open',
			\ 'action_table'   : {},
			\ 'parents'        : ['k_p4'],
			\ }

let s:kind_depot.action_table.a_open = {
			\ 'description' : '�J��',
			\ }
function! s:kind_depot.action_table.a_open.func(candidate) "{{{
	exe 'edit '.s:find_filepath_from_depot(a:candidate)
endfunction "}}}

let s:kind_depot.action_table.yank = {
			\ 'description' : '',
			\ 'is_selectable' : 1, 
			\ }
function! s:kind_depot.action_table.yank.func(candidates) "{{{
	let tmps = []
	for candidate in a:candidates
		call add(tmps, s:find_filepath_from_depot(candidate))
	endfor
	let @" = join(tmps, "\n")
	let @+ = join(tmps, "\n")
endfunction "}}}

let s:kind_depot.action_table.preview = {
			\ 'description' : 'preview' , 
			\ 'is_quit' : 0,
			\ }
function! s:kind_depot.action_table.preview.func(candidate) "{{{
	let path = s:find_filepath_from_depot(a:candidate) 
	exe 'pedit' path
endfunction "}}}

let s:kind_depot.action_table.a_p4_files = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̏��',
			\ }
function! s:kind_depot.action_table.a_p4_files.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#pfcmds('files','',join(depots)).outs
	call perforce_2#show(outs)
	sp
endfunction "}}}

let s:kind_depot.action_table.a_p4_move = {
			\ 'is_selectable' : 1 ,
			\ 'description' : '�ړ� ( ���O�̕ύX )' ,
			\ }
function! s:kind_depot.action_table.a_p4_move.func(candidates) "{{{
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
			let outs += perforce#pfcmds('edit','',path).outs
			let outs += perforce#pfcmds('move','',path.' '.dir.'/'.new).outs
			call perforce#LogFile(outs)
		endif
		"}}}
	else 
		" �����I���̏ꍇ "{{{

		let g:pfmove_tmpfile = copy(g:perforce_tmp_file)
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
		call perforce#util#event_save_file(g:pfmove_tmpfile, names, 'common#do_move', [g:pfmove_oris, g:pfmove_tmpfile])

		"}}}
	endif 


endfunction "}}}

let s:kind_depot.action_table.delete = { 
			\ 'description' : '���� ( delete ������ ) ',
			\ 'is_quit' : 0, 
			\ }
function! s:kind_depot.action_table.delete.func(candidate) "{{{
	let depot = a:candidate.action__depot
	call perforce#common#LogFile('diff', 1, perforce#pfcmds('diff','',depot).outs)
	wincmd p
endfunction "}}}

let s:kind_depot.action_table.a_p4_diff = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '����',
			\ 'is_quit' : 0,
			\ }
function! s:kind_depot.action_table.a_p4_diff.func(candidates) "{{{
	let args = map(copy(a:candidates),"v:val.action__depot")
	call unite#start_temporary([insert(args,'p4_diff')]) 
endfunction "}}}

let s:kind_depot.action_table.a_p4_diff_tool = {
			\ 'is_selectable' : 1 ,  
			\ 'description' : '���� ( TOOL )' ,
			\ }
function! s:kind_depot.action_table.a_p4_diff_tool.func(candidates) "{{{
	for l:candidate in a:candidates
		let depot = l:candidate.action__depot
		call perforce#pfDiff(depot)
	endfor
endfunction "}}}

let s:kind_depot.action_table.a_p4_reopen = {
			\ 'description' : '�`�F���W���X�g�̕ύX' ,
			\ 'is_selectable' : 1 ,
			\ }
function! s:kind_depot.action_table.a_p4_reopen.func(candidates) "{{{
	let reopen_depots= [] " # ������
	for l:candidate in a:candidates
		call add(reopen_depots, l:candidate.action__depot) " # �ۑ�
	endfor

	call unite#start_temporary([insert(reopen_depots,'p4_changes_pending_reopen')])
endfunction "}}}

let s:kind_depot.action_table.a_p4_filelog = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '����',
			\ }
function! s:kind_depot.action_table.a_p4_filelog.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	call unite#start([insert(depots, 'p4_filelog')])
endfunction "}}}

let s:kind_depot.action_table.a_p4_sync = { 
			\ 'is_selectable' : 1, 
			\ 'description' : '�t�@�C���̍ŐV����',
			\ }
function! s:kind_depot.action_table.a_p4_sync.func(candidates) "{{{
	let depots = map(copy(a:candidates),"v:val.action__depot")
	let outs = perforce#pfcmds('sync','',join(depots)).outs
	call perforce#LogFile(outs)
endfunction "}}}

function! s:copy_file(depot, client, root) "{{{

	let depot  = a:depot
	let file1  = perforce#get_path_from_depot(depot)
	let port   = matchstr(a:client, '-p\s\+\zs\S*')
	let port   = substitute(port, ':', '', 'g')

	" �󔒂ƈ������Ȃ��ꍇ�́Adefault��ݒ肷��
	let root2 = perforce#data#get('g:perforce_merge_default_path')


	" ������ \ ���폜����
	let root2 = substitute(root2,'/$','','')

	" �擪��\\���폜����
	let depot = substitute(depot, '//','','')
	
	" ClientPath���폜����
	let root1  = a:root
	let root1  = substitute(root1, '/', '\','g')

	" �u�����邽�߁A�X�y�[�X�̓G�X�P�[�v����
	let root1 = escape(root1,'\')

	" ���[�g�̍폜
	let path1 = substitute(file1, root1,'','')

	" �R�s�[��
	let file2 = root2.'/new/'.port.'/'.depot 

	" �ϊ�
	let file1 = substitute(file1, '/','\','g')
	let file2 = substitute(file2, '/','\','g')

	" �t�H���_�̍쐬
	let cmd = 'mkdir "'.fnamemodify(file2,':h').'"'
	echo cmd
	call system(cmd)

	" �R�s�[����
	let cmd = 'copy "'.file1.'" "'.file2.'"'
	echo cmd
	call system(cmd)

endfunction
"}}}
"
let s:kind_depot.action_table.a_p4_dir_copy = {
	\ 'description' : 'dir�ŃR�s�[����',
	\ 'is_selectable' : 1,
	\ }

function! s:kind_depot.action_table.a_p4_dir_copy.func(candidates) "{{{
	let root_cache = {}
	for candidate in a:candidates
		let client = candidate.action__client
		if !exists('root_cache[client]')
			let root_cache[client] = perforce#util#get_client_root_from_client(client)
		endif
		call s:copy_file(candidate.action__depot, client, root_cache[client].root)
	endfor
endfunction "}}}

let s:kind_depot.action_table.a_p4_depot_copy = {
	\ 'description' : 'depot�ŃR�s�[����',
	\ 'is_selectable' : 1,
	\ }
function! s:kind_depot.action_table.a_p4_depot_copy.func(candidates) "{{{
	for candidate in a:candidates
		let client = candidate.action__client
		call s:copy_file(candidate.action__depot, client, '')
	endfor
endfunction "}}}
"
if 1
	call unite#define_kind(s:kind_depot)
endif

let &cpo = s:save_cpo
unlet s:save_cpo

