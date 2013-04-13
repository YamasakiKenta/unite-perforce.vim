let s:save_cpo = &cpo
set cpo&vim

function! s:get_path_from_have(str) 
	let rtn = matchstr(a:str,'.\{-}#\d\+ - \zs.*')
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction

function! s:get_paths_from_haves(strs) 
	return map(a:strs,"s:get_path_from_have(v:val)")
endfunction

function! s:get_paths_from_fname(str) 
	" ファイルを検索
	let outs = perforce#cmd#base('have','',perforce#get_dd(a:str)).outs " # ファイル名の取得
	return s:get_paths_from_haves(outs)                   " # ヒットした場合
endfunction

function! s:pfdiff_from_fname(fname) "{{{
	" ********************************************************************************
	" perforceないからファイル名から検索して、全て比較
	" @param[in]	fname	比較したいファイル名
	" ********************************************************************************
	"
	" ファイル名のみの取出し
	let file = fnamemodify(a:fname,":t")

	let paths = s:get_paths_from_fname(file)

	call perforce#LogFile(paths)
	for path in paths 
		call perforce#diff#main(path)
	endfor
endfunction
"}}}

function! perforce#diff#main(path) "{{{
	" ********************************************************************************
	" ファイルをTOOLを使用して比較します
	" @param[in]	path		比較するパス ( path or depot )
	" ********************************************************************************

	" ファイルの比較
	let path = a:path

	" 最新 REV のファイルの取得 "{{{
	let outs = perforce#cmd#base('print','',' -q '.perforce#common#get_kk(path)).outs

	" エラーが発生したらファイルを検索して、すべてと比較 ( 再帰 )
	if outs[0] =~ "is not under client's root "
		call s:pfdiff_from_fname(path)
		return
	endif

	"tmpファイルの書き出し
	call writefile(outs,g:perforce_tmp_file)
	"}}}

	" 改行が一致しないので保存し直す "{{{
	exe 'sp' g:perforce_tmp_file
	set ff=dos
	wq
	"}}}

	" depotならpathに変換
	if path =~ "^//depot.*"
		let path = perforce#get#path#from_depot(path)
	endif

	" 実際に比較 
	call s:pf_diff_tool(g:perforce_tmp_file,path)

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
