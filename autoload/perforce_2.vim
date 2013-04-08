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
endfunction "}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" @param[in] add_flg true : クライアントに存在しない場合は、ファイルを追加
	" @param[in] a:000     {ファイル名}     値がない場合は、現在のファイルを編集する
	" @retval    なし
	" ********************************************************************************
	"
	" 編集するファイ目名の取得

	if a:0 == 0
		let _files = [perforce#common#get_now_filename()]
	else
		" ファイル名が指定されている場合
		let _files = a:000
	endif


	" init
	let file_d = {
				\ 'add' : '',
				\ 'edit' : '',
				\ 'null' : '',
				\ }

	" ファイルが存在しない場合、追加する
	for _file in _files
		let cmd = 'null'
		if perforce#is_p4_have(_file)
			let cmd = 'edit'
		else
			if ( a:add_flg == 1 )
				let cmd = 'add'
			endif
		endif

		let file_d[cmd] = file_d[cmd].' '.perforce#common#get_kk(_file)
	endfor

	unlet file_d['null']

	" init 
	let outs = []

	" コマンドを実行する
	for cmd in keys(file_d)
		let _file = file_d[cmd]
		if _file != ''
			call extend(outs, perforce#pfcmds_new_outs(cmd, '', _file))
		endif
	endfor

	call perforce#LogFile(outs)
endfunction
"}}}
function! perforce_2#pfDiff(...) "{{{
	" ********************************************************************************
	" @param[in] ファイル名
	" ********************************************************************************
	let file_ = call('perforce#util#get_files', a:000)[0]
	return perforce#pfDiff(file_)
endfunction
"}}}
function! perforce_2#revert(...) "{{{
	" ********************************************************************************
	" @param[in] ファイル名
	" ********************************************************************************
	let file_ = call(perforce#util#get_files, a:000)[0]
	let file_ = perforce#common#get_kk(file_)
	if perforce#is_p4_have(file_)
		let outs = perforce#pfcmds_new_outs('revert','',' -a '.file_)
	else
		let outs = perforce#pfcmds_new_outs('revert','',file_)
	endif
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
	
	let cmd = g:perforce_merge_tool.' "'.path.'" "'.perforce#get_PFCLIENTPATH().'"'

	exe '!start '.cmd

endfunction
"}}}
function! perforce_2#show(str)
	call perforce#common#LogFile('p4show', 1, a:str)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
