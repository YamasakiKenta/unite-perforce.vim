function! perforce#data#init() "{{{
let g:unite_pf_data = {'__order' : [], '__file' : $PFDATA }
call unite_setting_ex#add('g:unite_pf_data' , 'is_submit_flg'            , 'サブミットを許可'             , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'g_changes_only'           , 'フィルタ'                     , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'user_changes_only'        , 'ユーザー名でフィルタ'         , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'client_changes_only'      , 'クライアントでフィルタ'       , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'filters_flg'              , '除外リストを使用する'         , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'filters'                  , '除外リスト'                   , 'list'   , [-1, 'tag', 'snip']        )
call unite_setting_ex#add('g:unite_pf_data' , 'g_show'                   , 'ファイル数'                   , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'show_max_flg'             , 'ファイル数の制限'             , 'bool'   , 0                          )
call unite_setting_ex#add('g:unite_pf_data' , 'show_max'                 , 'ファイル数'                   , 'select' , [1, 5, 10]                 )
call unite_setting_ex#add('g:unite_pf_data' , 'g_is_out'                 , '実行結果'                     , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'is_out_flg'               , '実行結果を出力する'           , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'is_out_echo_flg'          , '実行結果を出力する[echo]'     , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'show_cmd_flg'             , 'p4 コマンドを表示する'        , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'show_cmd_stop_flg'        , 'p4 コマンドを表示する[stop]'  , 'bool'   , 1                          )
call unite_setting_ex#add('g:unite_pf_data' , 'g_diff'                   , 'Diff'                         , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'is_vimdiff_flg'           , 'vimdiff を使用する'           , 'bool'   , 0                          )
call unite_setting_ex#add('g:unite_pf_data' , 'diff_tool'                , 'Diff で使用するツール'        , 'select' , [1, 'WinMergeU']           )
call unite_setting_ex#add('g:unite_pf_data' , 'g_ClientMove'             , 'ClientMove'                   , 'title'  , -1                         )
call unite_setting_ex#add('g:unite_pf_data' , 'ClientMove_recursive_flg' , 'ClientMoveで再帰検索をするか' , 'bool'   , 0                          )
call unite_setting_ex#add('g:unite_pf_data' , 'ClientMove_defoult_root'  , 'ClientMoveの初期フォルダ'     , 'select' , [1, 'c:\tmp', 'c:\p4tmp']  )
call unite_setting_ex#add('g:unite_pf_data' , 'g_other'                  , 'その他'                       , 'title'  , -1                         )
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
