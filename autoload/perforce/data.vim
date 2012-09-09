let s:save_data_type = 1 " 新しい
function! s:set_pf_settings(type, description, kind_val ) "{{{
	" ********************************************************************************
	" pf_settings を追加します
	" ********************************************************************************
	" 表示順に追加
	let s:pf_settings_orders += [a:type]

	let g:pf_settings[a:type] = {
				\ 'common' : a:kind_val,
				\ 'description' : a:description,
				\ }

endfunction "}}}
function! s:data_load(file) "{{{
	" ********************************************************************************
	" 設定ファイルの読み込み
	" param[in]		file		設定ファイル名
	" ********************************************************************************

	" ファイルが見つからない場合は終了
	if filereadable(a:file) == 0
		echo 'Error - not fine '.a:file
		return
	endif

	if s:save_data_type == 0
		" ファイルを読み込む
		let datas = readfile(a:file.'_1')

		" データを設定する
		for data in datas
			let tmp = split(data,"\t")
			exe 'let g:pf_settings["'.join(tmp[0:-2],'"]["').'"] = '.tmp[-1]

			" 型が変わるため、初期化が必要
		endfor
	else
		exe 'let g:pf_settings = '.join(readfile(a:file.'_2'))
	endif

endfunction "}}}
function! s:get_pf_settings_from_lists(datas) "{{{
	" ********************************************************************************
	" BIT 演算によって、データを取得する
	" @param[in]	datas	{ bit, 文字列, ... } 
	" @retval   	rtns 	リストを返す
	" ********************************************************************************

	if a:datas[0] < 0
		" 全部返す
		let rtns = a:datas[1:]
	else
		" 有効なリストの取得 ( 一つ目は、フラグが入っているためスキップする )
		let nums = perforce#common#bit#get_nums_form_bit(a:datas[0]*2)

		" 有効な引数のみ返す
		let rtns = map(copy(nums), 'a:datas[v:val]')

	endif

	return rtns

endfunction "}}}
"@ main
function! perforce#data#init() "{{{
	" ********************************************************************************
	" 設定変数の初期化
	" ********************************************************************************

	if exists('g:pf_settings')
		return
	else
		" init
		let g:pf_settings = {}
		let s:pf_settings_orders = []

		" 並び替え用の変数の作成
		call s:set_pf_settings ( 'is_submit_flg'            , 'サブミットを許可'            , 1                         ) 
		call s:set_pf_settings ( 'g_changes_only'           , 'フィルタ'                    , -1                        ) 
		call s:set_pf_settings ( 'user_changes_only'        , 'ユーザー名でフィルタ'        , 1                         ) 
		call s:set_pf_settings ( 'client_changes_only'      , 'クライアントでフィルタ'      , 1                         ) 
		call s:set_pf_settings ( 'filters_flg'              , '除外リストを使用する'        , 1                         )
		call s:set_pf_settings ( 'filters'                  , '除外リスト'                  , [-1,'tag','snip']         ) 
		call s:set_pf_settings ( 'g_show'                   , 'ファイル数'                  , -1                        ) 
		call s:set_pf_settings ( 'show_max_flg'             , 'ファイル数の制限'            , 0                         ) 
		call s:set_pf_settings ( 'show_max'                 , 'ファイル数'                  , [1,5,10]                  ) 
		call s:set_pf_settings ( 'g_is_out'                 , '実行結果'                    , -1                        ) 
		call s:set_pf_settings ( 'is_out_flg'               , '実行結果を出力する'          , 1                         ) 
		call s:set_pf_settings ( 'is_out_echo_flg'          , '実行結果を出力する[echo]'    , 1                         ) 
		call s:set_pf_settings ( 'show_cmd_flg'             , 'p4 コマンドを表示する'       , 1                         ) 
		call s:set_pf_settings ( 'show_cmd_stop_flg'        , 'p4 コマンドを表示する(stop)' , 1                         ) 
		call s:set_pf_settings ( 'g_diff'                   , 'Diff'                        , -1                        ) 
		call s:set_pf_settings ( 'is_vimdiff_flg'           , 'vimdiff を使用する'          , 0                         ) 
		call s:set_pf_settings ( 'diff_tool'                , 'Diff で使用するツール'       , [1,'WinMergeU']           ) 
		call s:set_pf_settings ( 'g_ClientMove'             , 'ClientMove'                  , -1                        ) 
		call s:set_pf_settings ( 'ClientMove_recursive_flg' , 'ClientMoveで再帰検索をするか', 0                         ) 
		call s:set_pf_settings ( 'ClientMove_defoult_root'  , 'ClientMoveの初期フォルダ'    , [1,'c:\tmp','c:\p4tmp']   ) 
		call s:set_pf_settings ( 'g_other'                  , 'その他'                      , -1                        ) 
		call s:set_pf_settings ( 'ports'                    , 'perforce port'               , [1,'localhost:1818']      ) 

		" 設定を読み込む
		call s:data_load($PFDATA)

		" クライアントデータの読み込み
		call perforce#get_client_data_from_info()

	endif
endfunction "}}}
function! perforce#data#set(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind] = a:val
endfunction "}}}
function! perforce#data#delete(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind] = a:val
endfunction "}}}
function! perforce#data#set_list(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind][0] = a:val
endfunction "}}}
function! perforce#data#get_orig(type, kind) "{{{
	" ********************************************************************************
	" 設定データを取得する
	" @param[in]	type		pf_settings の設定の種類
	" @param[in]	kind		common など, source の種類
	" @retval		rtns 		取得データ
	" ********************************************************************************
	" 設定がない場合は、共通を呼び出す
	let kind = perforce#data#get_kind(a:type, a:kind)

	let val = g:pf_settings[a:type][kind]

	let valtype = type(val)

	let rtns = {
				\ 'datas' : val,
				\ 'kind' : kind,
				\ }

	return rtns
endfunction "}}}
function! perforce#data#get(type, kind) "{{{
	" ********************************************************************************
	" 設定データを取得する
	" @param[in]	type		pf_settings の設定の種類
	" @param[in]	kind		common など, source の種類
	" @retval		rtns 		取得データ
	" ********************************************************************************
	" 設定がない場合は、共通を呼び出す
	let kind = perforce#data#get_kind(a:type, a:kind)

	let val = g:pf_settings[a:type][kind]

	let valtype = type(val)

	let rtns = {}
	if valtype == 3
		" リストの場合は、引数で取得する
		let rtns.datas = s:get_pf_settings_from_lists(val)
	else
		let rtns.datas = val
	endif

	let rtns.kind = kind

	return rtns
endfunction "}}}
function! perforce#data#save(file) "{{{
	" ********************************************************************************
	" 設定ファイルを保存する
	" param[in]		file		設定ファイル名
	" ********************************************************************************

	if s:save_data_type == 0
		let datas = []

		for type in keys(g:pf_settings)
			for val in keys(g:pf_settings[type])
				if val != 'description'
					let datas += [type."\t".val."\t".string(g:pf_settings[type][val])."\r"]
				endif
			endfor
		endfor


		" 書き込む
		call writefile(datas, a:file.'_1')
	else
		call writefile([string(g:pf_settings)], a:file.'_2')
	endif

endfunction "}}}
function! perforce#data#get_orders() "{{{
	"********************************************************************************
	" unite で表示するデータ
	"********************************************************************************
	return s:pf_settings_orders
endfunction "}}}
function! perforce#data#get_kind(type, kind) "{{{
	if exists('g:pf_settings[a:type][a:kind]')
		let kind = a:kind
	else
		let kind = 'common'
	endif

	return kind
endfunction "}}}
