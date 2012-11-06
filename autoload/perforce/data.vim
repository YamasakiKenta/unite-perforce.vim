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
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_フィルタ') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'user_changes_only'             ,'ユーザー名でフィルタ'         , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'client_changes_only'           ,'クライアントでフィルタ'       , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'filters_flg'                   ,'除外リストを使用する'         , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'filters'                       ,'除外リスト'                   , 'list_ex'      , [[1,2], 'tag', 'snip']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_ファイル数') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_max_flg'                  ,'ファイル数の制限'             , 'bool'      , 0) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_max'                      ,'ファイル数'                   , 'select'    , [[1], 5, 10]) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_実行結果') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_out_flg'                    ,'実行結果を出力する'           , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_out_echo_flg'               ,'実行結果を出力する[echo]'     , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_cmd_flg'                  ,'p4 コマンドを表示する'        , 'bool'      , 1) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'show_cmd_stop_flg'             ,'p4 コマンドを表示する[stop]'  , 'bool'      , 1) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_DIFF') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_vimdiff_flg'                ,'vimdiff を使用する'           , 'bool'      , 0) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'diff_tool'                     ,'Diff で使用するツール'        , 'select'    , [[1], 'WinMergeU']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_ClientMove') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'ClientMove_recursive_flg'      ,'ClientMoveで再帰検索をするか' , 'bool'      , 0) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'ClientMove_defoult_root'       ,'ClientMoveの初期フォルダ'     , 'select'    , [[1], 'c:\tmp', 'c:\p4tmp']) 
		call unite_setting_ex#add_title ( 'g:unite_pf_data' , '_Ohter') 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'g:perforce_merge_tool'         ,''                             , 'select'    , [[1], 'winmergeu /S']) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'g:perforce_merge_default_path' ,''                             , 'select'    , [[1], 'c:\tmp']) 
		call unite_setting_ex#add       ( 'g:unite_pf_data' , 'is_submit_flg'                 ,'サブミットを許可'             , 'bool'      , 0) 
	endif

	nnoremap ;pp<CR> :<C-u>call unite#start([['settings_ex', 'g:unite_pf_data']])<CR>

endfunction "}}}
function! perforce#data#get(valname, ...) "{{{
	let kind = '__common'
	return unite_setting_ex#get('g:unite_pf_data', a:valname, kind)
endfunction "}}}
