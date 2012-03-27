function! g:PerforceDiff(file,file2) "{{{
	" ********************************************************************************
	" DIFFツールの登録
	" @param[in]	file	過去のファイル
	" @param[in]	file2	現在のファイル
	" ********************************************************************************
	if 1
		call system('WinMergeU '.okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	else
		"
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call okazu#Map_diff()
	endif

endfunction "}}}
