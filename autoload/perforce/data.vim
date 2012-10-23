function! perforce#data#init() "{{{
let g:unite_pf_data = {'__order' : [], '__file' : $PFDATA }
call unite_setting_ex#add('g:unite_pf_data' , 'is_submit_flg'            , '�T�u�~�b�g������'             , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'g_changes_only'           , '�t�B���^'                     , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'user_changes_only'        , '���[�U�[���Ńt�B���^'         , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'client_changes_only'      , '�N���C�A���g�Ńt�B���^'       , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'filters_flg'              , '���O���X�g���g�p����'         , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'filters'                  , '���O���X�g'                   , 'list'   , [-1, 'tag', 'snip']        )
call unite_setting_ex#add('g:unite_pf_data' , 'g_show'                   , '�t�@�C����'                   , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'show_max_flg'             , '�t�@�C�����̐���'             , 'bool'   , 0                          )
call unite_setting_ex#add('g:unite_pf_data' , 'show_max'                 , '�t�@�C����'                   , 'select' , [1, 5, 10]                 )
call unite_setting_ex#add('g:unite_pf_data' , 'g_is_out'                 , '���s����'                     , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'is_out_flg'               , '���s���ʂ��o�͂���'           , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'is_out_echo_flg'          , '���s���ʂ��o�͂���[echo]'     , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'show_cmd_flg'             , 'p4 �R�}���h��\������'        , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'show_cmd_stop_flg'        , 'p4 �R�}���h��\������[stop]'  , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'g_diff'                   , 'Diff'                         , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'is_vimdiff_flg'           , 'vimdiff ���g�p����'           , 'bool'   , 0                          )
call unite_setting_ex#add('g:unite_pf_data' , 'diff_tool'                , 'Diff �Ŏg�p����c�[��'        , 'select' , [1, 'WinMergeU']           )
call unite_setting_ex#add('g:unite_pf_data' , 'g_ClientMove'             , 'ClientMove'                   , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'ClientMove_recursive_flg' , 'ClientMove�ōċA���������邩' , 'bool'   , 0                          )
call unite_setting_ex#add('g:unite_pf_data' , 'ClientMove_defoult_root'  , 'ClientMove�̏����t�H���_'     , 'select' , [1, 'c:\tmp', 'c:\p4tmp']  )
call unite_setting_ex#add('g:unite_pf_data' , 'g_other'                  , '���̑�'                       , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'ports'                    , 'perforce port'                , 'list'   , [1, 'localhost:1818']      )
call unite_setting_ex#add('g:unite_pf_data' , 'users'                    , 'perforce user'                , 'list'   , [1, 'yamasaki']            )
call unite_setting_ex#add('g:unite_pf_data' , 'clients'                  , 'perforce client'              , 'list'   , [1, 'main']                )
call unite_setting_ex#load('g:unite_pf_data')

nnoremap ;pp<CR> :<C-u>call unite#start([['settings_ex', 'g:unite_pf_data']])<CR>
endfunction "}}}
function! perforce#data#get(valname, ...) "{{{
	"let kind = get(a:, 0, '__common')
	let kind = '__common'
	return unite_setting_ex#get('g:unite_pf_data', a:valname, kind)
endfunction "}}}
