let s:save_cpo = &cpo
set cpo&vim


function! s:init() "{{{
	if exists('s:init_flg')
		return
	endif

	echo "load ..."

	let s:init_flg = 1

	let file_ = expand('~/.vim-unite-perforce')

	call s:perforce_init(file_)
	call s:perforce_add_title ( '_clients') 
	call s:perforce_add       ( 'use_default'                   ,''                             , 'bool'      , 1)
	call s:perforce_add       ( 'diff -dw'                      ,'�󔒂𖳎�����'               , 'bool'      , 1)
	call s:perforce_add       ( 'clients'                       ,'perforce clients'             , 'list_ex'   , [[1,2], '-p localhost:1818 -c main_1', '-p localhost:1668 -c main_1']) 
	call s:perforce_add       ( 'ports'                         ,'perforce ports'               , 'list_ex'   , [[1,2], 'localhost:1668', 'localhost:1818']) 
	call s:perforce_add       ( 'users'                         ,'perforce user'                , 'list_ex'   , [[1], 'yamasaki']) 
	call s:perforce_add_title ( '_�t�B���^') 
	call s:perforce_add       ( 'user_changes_only'             ,'���[�U�[���Ńt�B���^'         , 'bool'      , 1) 
	call s:perforce_add       ( 'client_changes_only'           ,'�N���C�A���g�Ńt�B���^'       , 'bool'      , 1) 
	call s:perforce_add       ( 'filters_flg'                   ,'���O���X�g���g�p����'         , 'bool'      , 1) 
	call s:perforce_add       ( 'filters'                       ,'���O���X�g'                   , 'list_ex'      , [[1,2], 'tag', 'snip']) 
	call s:perforce_add_title ( '_�t�@�C����') 
	call s:perforce_add       ( 'show_max_flg'                  ,'�t�@�C�����̐���'             , 'bool'      , 0) 
	call s:perforce_add       ( 'show_max'                      ,'�t�@�C����'                   , 'select'    , [[1], 5, 10]) 
	call s:perforce_add_title ( '_���s����') 
	call s:perforce_add       ( 'is_out_flg'                    ,'���s���ʂ��o�͂���'           , 'bool'      , 1) 
	call s:perforce_add       ( 'is_out_echo_flg'               ,'���s���ʂ��o�͂���[echo]'     , 'bool'      , 1) 
	call s:perforce_add       ( 'show_cmd_flg'                  ,'p4 �R�}���h��\������'        , 'bool'      , 1) 
	call s:perforce_add       ( 'show_cmd_stop_flg'             ,'p4 �R�}���h��\������[stop]'  , 'bool'      , 1) 
	call s:perforce_add_title ( '_DIFF') 
	call s:perforce_add       ( 'is_vimdiff_flg'                ,'vimdiff ���g�p����'           , 'bool'      , 0) 
	call s:perforce_add       ( 'diff_tool'                     ,'Diff �Ŏg�p����c�[��'        , 'select'    , [[1], 'WinMergeU']) 
	call s:perforce_add_title ( '_ClientMove') 
	call s:perforce_add       ( 'ClientMove_recursive_flg'      ,'ClientMove�ōċA���������邩' , 'bool'      , 0) 
	call s:perforce_add_title ( '_Ohter') 
	call s:perforce_add       ( 'is_submit_flg'                 ,'�T�u�~�b�g������'             , 'bool'      , 0) 
	call s:perforce_add_title ( '�t�@�C������')
	call s:perforce_add       ( 'g:perforce_merge_tool'         ,'�}�[�W�R�}���h'               , 'select'    , [[1], 'winmergeu /S']) 
	call s:perforce_add       ( 'g:perforce_merge_default_path' ,'�}�[�W�A��r��t�H���_'       , 'select'    , [[1], 'c:\tmp']) 
	call s:perforce_load()

	echo 'end...'

endfunction "}}}

function! s:perforce_add_title(...) "{{{
	return call('unite_setting_ex#add_title' , extend(['g:unite_pf_data'] , a:000))
endfunction
"}}}
function! s:perforce_add(...) "{{{
	return call('unite_setting_ex#add'       , extend(['g:unite_pf_data'] , a:000))
endfunction
"}}}
function! s:perforce_init(...) "{{{
	return call('unite_setting_ex#init'      , extend(['g:unite_pf_data'] , a:000))
endfunction
"}}}
function! s:perforce_load(...) "{{{
	return call('unite_setting_ex#load'      , extend(['g:unite_pf_data'] , a:000))
endfunction
"}}}
"
function! perforce#data#get(valname, ...) "{{{
	call s:init()
	let kind = '__common'
	return unite_setting_ex#get('g:unite_pf_data', a:valname, kind)
endfunction "}}}
function! perforce#data#setting() "{{{
	call s:init()
	call unite#start([['settings_ex', 'g:unite_pf_data']])
endfunction
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

