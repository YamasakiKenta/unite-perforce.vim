let s:save_cpo = &cpo
set cpo&vim

let g:perforce_merge_tool         = get(g:, 'perforce_merge_tool', 'winmergeu /S')
let g:perforce_merge_default_path = get(g:, 'perforce_merge_default_path', 'c:\tmp')

function! perforce_2#common_action_out(outs)
	" ********************************************************************************
	" @par       action 終了時に呼び出す
	" @param[in] 実行結果 ( Log で表示する文字列 ) 
	" @retval    
	" ********************************************************************************
		call perforce#LogFile(a:outs)
		"call unite#force_redraw()
endfunction
function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" 補完 : perforce 上に存在するファイルを表示する
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
"}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" 編集状態、もしくは追加状態にする
	" @param[in] a:add_flg = 1 - TREUE : クライアントに存在しない場合は、ファイルを追加
	" @param[in] a:000     {ファイル名}     値がない場合は、現在のファイルを編集する
	" ********************************************************************************
	"
	" 編集するファイ目名の取得
	let _files = call('perforce#util#get_files', a:000)

	" init
	let files_d = {
				\ 'add'  : [],
				\ 'edit' : [],
				\ }

	" グループの分類
	let data_d = perforce#is_p4_haves(_files)

	let files_d['edit']  = data_d.true

	if ( a:add_flg == 1 )
		let files_d['add']   = data_d.false
	endif

	" コマンドを実行する
	let outs = []
	for cmd in keys(files_d)
		let files_ = files_d[cmd]
		if len(files_) > 0
			call extend(outs, perforce#cmd#files_outs(cmd, files_))
		endif
	endfor

	" ログの表示
	call perforce#LogFile(outs)
endfunction
"}}}
function! perforce_2#revert(...) "{{{
	" ********************************************************************************
	" @param[in] ファイル名
	" ********************************************************************************
	let files_ = call('perforce#util#get_files', a:000)

	" ★ edit ,add をまねる

	let data_d = perforce#is_p4_haves(files_)
	" ★まとめる
	let outs = perforce#cmd#files_outs('revert -a', data_d.true)
	let outs = perforce#cmd#files_outs('revert', data_d.false)

	call perforce#LogFile(outs)
endfunction 
"}}}
function! perforce_2#echo_error(message) "{{{
  echohl WarningMsg 
  echo a:message 
  echohl None
endfunction
"}}}
function! perforce_2#pf_merge(...) "{{{
	" ********************************************************************************
	" 現在のクライアントと、マージします。
	" @param[in]	path	比較するファイル
	" @retval       NONE
	" ********************************************************************************
	let path = ( a:1 == "" ) ? g:perforce_merge_default_path : a:1

	" ★ デフォルトになっているが、複数ある場合はどうするか
	" ★ 自動で追加するフラグを設定する
	let port = substitute(perforce#get#PFPORT(), ':', '', 'g')
	
	let path = path.'/new/'.port

	let cmd = g:perforce_merge_tool.' "'.path.'" "'.perforce#get#PFCLIENTPATH().'"'

	exe '!start '.cmd

endfunction
"}}}
function! perforce_2#show(str)
	call perforce#common#LogFile('p4show', 1, a:str)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
