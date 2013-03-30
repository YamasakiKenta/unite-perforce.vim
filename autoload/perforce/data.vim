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
	call s:perforce_add       ( 'diff -dw'                      ,'空白を無視する'               , 'bool'      , 1)
	call s:perforce_add       ( 'clients'                       ,'perforce clients'             , 'list_ex'   , [[1,2], '-p localhost:1818 -c main_1', '-p localhost:1668 -c main_1']) 
	call s:perforce_add       ( 'ports'                         ,'perforce ports'               , 'list_ex'   , [[1,2], 'localhost:1668', 'localhost:1818']) 
	call s:perforce_add       ( 'users'                         ,'perforce user'                , 'list_ex'   , [[1], 'yamasaki']) 
	call s:perforce_add_title ( '_フィルタ') 
	call s:perforce_add       ( 'user_changes_only'             ,'ユーザー名でフィルタ'         , 'bool'      , 1) 
	call s:perforce_add       ( 'client_changes_only'           ,'クライアントでフィルタ'       , 'bool'      , 1) 
	call s:perforce_add       ( 'filters_flg'                   ,'除外リストを使用する'         , 'bool'      , 1) 
	call s:perforce_add       ( 'filters'                       ,'除外リスト'                   , 'list_ex'      , [[1,2], 'tag', 'snip']) 
	call s:perforce_add_title ( '_ファイル数') 
	call s:perforce_add       ( 'show_max_flg'                  ,'ファイル数の制限'             , 'bool'      , 0) 
	call s:perforce_add       ( 'show_max'                      ,'ファイル数'                   , 'select'    , [[1], 5, 10]) 
	call s:perforce_add_title ( '_実行結果') 
	call s:perforce_add       ( 'is_out_flg'                    ,'実行結果を出力する'           , 'bool'      , 1) 
	call s:perforce_add       ( 'is_out_echo_flg'               ,'実行結果を出力する[echo]'     , 'bool'      , 1) 
	call s:perforce_add       ( 'show_cmd_flg'                  ,'p4 コマンドを表示する'        , 'bool'      , 1) 
	call s:perforce_add       ( 'show_cmd_stop_flg'             ,'p4 コマンドを表示する[stop]'  , 'bool'      , 1) 
	call s:perforce_add_title ( '_DIFF') 
	call s:perforce_add       ( 'is_vimdiff_flg'                ,'vimdiff を使用する'           , 'bool'      , 0) 
	call s:perforce_add       ( 'diff_tool'                     ,'Diff で使用するツール'        , 'select'    , [[1], 'WinMergeU']) 
	call s:perforce_add_title ( '_ClientMove') 
	call s:perforce_add       ( 'ClientMove_recursive_flg'      ,'ClientMoveで再帰検索をするか' , 'bool'      , 0) 
	call s:perforce_add_title ( '_Ohter') 
	call s:perforce_add       ( 'is_submit_flg'                 ,'サブミットを許可'             , 'bool'      , 0) 
	call s:perforce_add_title ( 'ファイル操作')
	call s:perforce_add       ( 'g:perforce_merge_tool'         ,'マージコマンド'               , 'select'    , [[1], 'winmergeu /S']) 
	call s:perforce_add       ( 'g:perforce_merge_default_path' ,'マージ、比較先フォルダ'       , 'select'    , [[1], 'c:\tmp']) 
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

