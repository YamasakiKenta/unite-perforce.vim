function! perforce#data#init() "{{{
	let file_ = $PFDATA.'_2'
	if filereadable(file_)
	"if 0
		call unite_setting_ex#load('g:unite_pf_data', file_)
	else
		let g:unite_pf_data = {'__order' : [], '__file' : file_ }
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_clients') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'clients'                       ,'perforce clients'             , 'list_ex'   , [[1,2], '-p localhost:1818 -c main_1', '-p localhost:1668 -c main_1']) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'ports'                         ,'perforce ports'               , 'list_ex'   , [[1,2], 'localhost:1668', 'localhost:1818']) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'users'                         ,'perforce user'                , 'list_ex'   , [[1], 'yamasaki']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_�t�B���^') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'user_changes_only'             ,'���[�U�[���Ńt�B���^'         , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'client_changes_only'           ,'�N���C�A���g�Ńt�B���^'       , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'filters_flg'                   ,'���O���X�g���g�p����'         , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'filters'                       ,'���O���X�g'                   , 'list_ex'      , [[1,2], 'tag', 'snip']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_�t�@�C����') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_max_flg'                  ,'�t�@�C�����̐���'             , 'bool'      , 0) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_max'                      ,'�t�@�C����'                   , 'select'    , [[1], 5, 10]) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_���s����') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_out_flg'                    ,'���s���ʂ��o�͂���'           , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_out_echo_flg'               ,'���s���ʂ��o�͂���[echo]'     , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_cmd_flg'                  ,'p4 �R�}���h��\������'        , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_cmd_stop_flg'             ,'p4 �R�}���h��\������[stop]'  , 'bool'      , 1) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_DIFF') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_vimdiff_flg'                ,'vimdiff ���g�p����'           , 'bool'      , 0) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'diff_tool'                     ,'Diff �Ŏg�p����c�[��'        , 'select'    , [[1], 'WinMergeU']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_ClientMove') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'ClientMove_recursive_flg'      ,'ClientMove�ōċA���������邩' , 'bool'      , 0) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'ClientMove_defoult_root'       ,'ClientMove�̏����t�H���_'     , 'select'    , [[1], 'c:\tmp', 'c:\p4tmp']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_Ohter') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'g:perforce_merge_tool'         ,''                             , 'select'    , [[1], 'winmergeu /S']) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'g:perforce_merge_default_path' ,''                             , 'select'    , [[1], 'c:\tmp']) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_submit_flg'                 ,'�T�u�~�b�g������'             , 'bool'      , 0) 
	endif

	nnoremap ;pp<CR> :<C-u>call unite#start([['settings_ex', 'g:unite_pf_data']])<CR>

endfunction "}}}
function! perforce#data#get(valname, ...) "{{{
	let kind = '__common'
	return unite_setting_ex#get('g:unite_pf_data', a:valname, kind)
endfunction "}}}
