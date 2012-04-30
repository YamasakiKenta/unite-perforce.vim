function! g:PerforceDiff(file,file2) "{{{
	" ********************************************************************************
	" DIFFツールの登録
	" @param[in]	file	過去のファイル
	" @param[in]	file2	現在のファイル
	" @var g:pf_setting.bool.is_vimdiff_flg.value
	" 	TRUE 	vimdiffで比較する
	" @var g:pf_diff_tool
	" 	DiffTool名
	"
	" ********************************************************************************
	let g:tmp = ""
	if g:pf_setting.bool.is_vimdiff_flg.value
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call okazu#Map_diff()
	else
		call system(g:pf_diff_tool." ".okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	endif

endfunction "}}}
