" ********************************************************************************
" DIFFツールの登録
" @param[in]	file	過去のファイル
" @param[in]	file2	現在のファイル
" @var g:pf_settings.is_vimdiff_flg.common
" 	TRUE 	vimdiffで比較する
" @var g:pf_diff_tool
" 	DiffTool名
" ********************************************************************************
function! g:PerforceDiff(file,file2) "{{{
	if g:pf_settings.is_vimdiff_flg.common
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call okazu#Map_diff()
	else
		call system(perforce#get_pf_settings('diff_tool','common')[0].' '.okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	endif

endfunction "}}}
