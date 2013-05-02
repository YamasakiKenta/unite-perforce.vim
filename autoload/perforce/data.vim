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
	call s:perforce_add       ( 'g:unite_perforce_use_default'                   ,''                             , 'bool'          , 1)
	call s:perforce_add       ( 'g:unite_perforce_diff_dw'                       ,'空白を無視する'               , 'bool'          , 1)
	call s:perforce_add       ( 'g:unite_perforce_clients'                       ,'perforce clients'             , 'list_ex'       , {'nums' : [0,1], 'items' : ['-p localhost:1819']}) 
	call s:perforce_add       ( 'g:unite_perforce_user_changes_only'             ,'ユーザー名でフィルタ'         , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_client_changes_only'           ,'クライアントでフィルタ'       , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_filters_flg'                   ,'除外リストを使用する'         , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_filters'                       ,'除外リスト'                   , 'list_ex'       , {'nums' : [0,1], 'items' : ['tag', 'snip']}) 
	call s:perforce_add       ( 'g:unite_perforce_show_max_flg'                  ,'ファイル数の制限'             , 'bool'          , 0) 
	call s:perforce_add       ( 'g:unite_perforce_show_max'                      ,'ファイル数'                   , 'select'        , {'nums' : [0], 'items' : [5, 10]})
	call s:perforce_add       ( 'g:unite_perforce_is_out_flg'                    ,'実行結果を出力する'           , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_is_out_echo_flg'               ,'実行結果を出力する[echo]'     , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_show_cmd_flg'                  ,'p4 コマンドを表示する'        , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_show_cmd_stop_flg'             ,'p4 コマンドを表示する[stop]'  , 'bool'          , 1) 
	call s:perforce_add       ( 'g:unite_perforce_is_vimdiff_flg'                ,'vimdiff を使用する'           , 'bool'          , 0) 
	call s:perforce_add       ( 'g:unite_perforce_diff_tool'                     ,'Diff で使用するツール'        , 'select'        , {'nums' : [0],'items':[ 'WinMergeU']}) 
	call s:perforce_add       ( 'g:unite_perforce_is_submit_flg'                 ,'サブミットを許可'             , 'bool'          , 0) 
	call s:perforce_add       ( 'g:perforce_merge_tool'                          ,'マージコマンド'               , 'select'        , {'nums' : [0], 'items' :['winmergeu /S']}) 
	call s:perforce_add       ( 'g:perforce_merge_default_path'                  ,'マージ、比較先フォルダ'       , 'select'        , {'nums' : [0], 'items' :['c:\tmp']}) 
	call s:perforce_load()

	" 設定値で種類を選別する
	" bool -> 1 or 0
	" list_ex -> type(nums) = type([])
	" select  -> type(nums) = type(0)
	" const   -> const([])

	echo 'end...'

endfunction
"}}}

function! s:perforce_add(...) 
	return call('unite_setting_ex_3#add'       , extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_init(...) 
	return call('unite_setting_ex#init'      , extend(['g:unite_pf_data'] , a:000))
endfunction
function! s:perforce_load(...) 
	return call('unite_setting_ex#load'      , extend(['g:unite_pf_data'] , a:000))
endfunction
function! perforce#data#get(valname, ...) "{{{
	call s:init()
	let kind = '__common'
	return unite_setting_ex#get('g:unite_pf_data', a:valname, kind)
endfunction
"}}}
function! perforce#data#setting() "{{{
	call s:init()
	call unite#start([['settings_ex', 'g:unite_pf_data']])
endfunction
"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

