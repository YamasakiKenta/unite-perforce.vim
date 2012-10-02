let s:pf_settings_orders  = []
let g:pf_settings         = {}
let s:pf_settings_default = {}

"@ sub
function! s:data_load(file) "{{{
	" ********************************************************************************
	" 設定ファイルの読み込み
	" param[in]		file		設定ファイル名
	" ********************************************************************************


	" ファイルが見つからない場合は終了
	if !filereadable(a:file)
		echo 'Error - not fine '.a:file
		return
	endif

	exe 'let tmp_dicts = '.join(readfile(a:file))

	" 存在する値のみ登録する
	for type in keys(tmp_dicts)
		for kind in keys(tmp_dicts[type])
			call perforce#data#set_orig( type, kind, tmp_dicts[type][kind])
		endfor
	endfor

endfunction "}}}
function! s:set_pf_settings_default(type, description, kind_type, kind_val ) "{{{
	" ********************************************************************************
	" pf_settings を追加します
	" ********************************************************************************
	" 表示順に追加
	let s:pf_settings_orders += [a:type]

	" 初期値を追加
	let s:pf_settings_default[a:type] = {
				\ 'common'      : a:kind_val,
				\ 'type'        : a:kind_type,
				\ 'description' : a:description,
				\ }

	let g:pf_settings[a:type] = {
				\ 'common'      : a:kind_val,
				\ 'type'        : a:kind_type,
				\ 'description' : a:description,
				\ }

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
		let rtns = copy(nums)
		call filter(rtns, "exists('a:datas[v:val]')")
		call map(rtns, "a:datas[v:val]")

	endif

	return rtns

endfunction "}}}
"@ main
function! perforce#data#init() "{{{
	" 設定変数の初期化
	call s:set_pf_settings_default ( 'is_submit_flg'            , 'サブミットを許可'             , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'g_changes_only'           , 'フィルタ'                     , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'user_changes_only'        , 'ユーザー名でフィルタ'         , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'client_changes_only'      , 'クライアントでフィルタ'       , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'filters_flg'              , '除外リストを使用する'         , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'filters'                  , '除外リスト'                   , 'strs' , [-1, 'tag', 'snip']          )
	call s:set_pf_settings_default ( 'g_show'                   , 'ファイル数'                   , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'show_max_flg'             , 'ファイル数の制限'             , 'bool'   , 0                          )
	call s:set_pf_settings_default ( 'show_max'                 , 'ファイル数'                   , 'strs'   , [1, 5, 10]                 )
	call s:set_pf_settings_default ( 'g_is_out'                 , '実行結果'                     , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'is_out_flg'               , '実行結果を出力する'           , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'is_out_echo_flg'          , '実行結果を出力する[echo]'     , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'show_cmd_flg'             , 'p4 コマンドを表示する'        , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'show_cmd_stop_flg'        , 'p4 コマンドを表示する[stop]'  , 'bool'   , 1                          )
	call s:set_pf_settings_default ( 'g_diff'                   , 'Diff'                         , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'is_vimdiff_flg'           , 'vimdiff を使用する'           , 'bool'   , 0                          )
	call s:set_pf_settings_default ( 'diff_tool'                , 'Diff で使用するツール'        , 'strs' , [1, 'WinMergeU']             )
	call s:set_pf_settings_default ( 'g_ClientMove'             , 'ClientMove'                   , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'ClientMove_recursive_flg' , 'ClientMoveで再帰検索をするか' , 'bool'   , 0                          )
	call s:set_pf_settings_default ( 'ClientMove_defoult_root'  , 'ClientMoveの初期フォルダ'     , 'strs' , [1, 'c:\tmp', 'c:\p4tmp']    )
	call s:set_pf_settings_default ( 'g_other'                  , 'その他'                       , 'title'  , -1                         )
	call s:set_pf_settings_default ( 'ports'                    , 'perforce port'                , 'strs' , [1, 'localhost:1818']        )
	call s:set_pf_settings_default ( 'users'                    , 'perforce user'                , 'strs' , [1, 'yamasaki']              )
	call s:set_pf_settings_default ( 'clients'                  , 'perforce client'              , 'strs' , [1, 'main']                  )

	" 設定を読み込む
	call s:data_load($PFDATA)

endfunction "}}}
function! perforce#data#save(file) "{{{
	" ********************************************************************************
	" 設定ファイルを保存する
	" param[in]		file		設定ファイル名
	" ********************************************************************************

		call writefile([string(g:pf_settings)], a:file)

endfunction "}}}
"@ get
function! perforce#data#get(type, ...) "{{{
	" ********************************************************************************
	" 設定データを取得する
	" @param[in]	type		pf_settings の設定の種類
	" @param[in]	kind		common など, source の種類
	" @retval		rtns 		取得データ
	" ********************************************************************************
	
	if a:0 > 0 
		let kind = a:1
	else
		let kind = 'common'
	endif

	" 設定がない場合は、共通を呼び出す
	let kind = perforce#data#get_kind(a:type, kind)

	if !exists("g:pf_settings[a:type][kind]")
		let g:pf_settings[a:type][kind] = s:pf_settings_default[a:type][kind]
	endif

	let val = g:pf_settings[a:type][kind]

	if type(val) == type([])
		" リストの場合は、引数で取得する
		let rtns = s:get_pf_settings_from_lists(val)
	else
		let rtns = val
	endif


	return rtns
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
function! perforce#data#get_bits(type, kind) "{{{
	let tmp_data_d = perforce#data#get_orig(a:type, a:kind)

	" bit の変換
	let tmp_num = tmp_data_d[0]
	let bits = []
	let num  = 1
	while ( tmp_num > 0 )
		call add(bits,  tmp_num % 2 ? num : 0)
		let tmp_num = tmp_num / 2
		let num = num * 2
	endwhile

	return bits

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

	return g:pf_settings[a:type][kind]

endfunction "}}}
"@ set
function! perforce#data#set(type, kind, val) "{{{
	let g:pf_settings[a:type][a:kind] = a:val
endfunction "}}}
function! perforce#data#set_orig(type, kind, val) "{{{
	"********************************************************************************
	" 値をそのまま代入する
	" param[in]  str 		type 	
	" param[in]  str 		kind	
	" param[out] void* 	val 	
	"********************************************************************************
	if exists("g:pf_settings[a:type][a:kind]")
		let g:pf_settings[a:type][a:kind] = a:val
	endif
endfunction "}}}
function! perforce#data#set_bits(type, kind, val) "{{{
	" ********************************************************************************
	" 使用する箇所のフラグを立てたものを代入する
	" ********************************************************************************
	exe 'let sum = '.join(a:val, '+')
	call perforce#data#set_bits_orig(a:type, a:kind, sum)
endfunction "}}}
function! perforce#data#set_bits_orig(type, kind, val) "{{{
"********************************************************************************
" bits をそのまま代入する
"********************************************************************************
	let g:pf_settings[a:type][a:kind][0] = a:val
endfunction "}}}
"@ delete
function! perforce#data#delete(type, kind, nums) "{{{
"********************************************************************************
" 拍所する番号がはいっている配列変数を代入する
"********************************************************************************
	let type = a:type
	let kind = a:kind
	let nums = a:nums

	" 並び替え
	call sort(nums)

	" 番号の取得
	let datas = perforce#data#get_orig(type, kind)
	
	" 更新
	let kind = perforce#data#get_kind(type, kind)

	" 選択番号の取得
	let bits = perforce#data#get_bits(type, kind)

	" 削除
	let cnt = 0
	let bitnum = 1
	for num in nums
		" 番号の更新
		let tmp_num = num - cnt
		if exists('datas[tmp_num]')
			unlet datas[tmp_num]
		endif
		if exists('bits[tmp_num]')
			unlet bits[tmp_num]
		endif
		let cnt    = cnt + 1
		let bitnum = bitnum * 2
	endfor

	" 選択番号の再設定
	call perforce#data#set_bits(type, kind, bits)

	" 設定
	call perforce#data#set(type, kind, datas)

endfunction "}}}
