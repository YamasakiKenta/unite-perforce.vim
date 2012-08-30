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
	if perforce#setting#get('is_vimdiff_flg', 'common').datas[0]
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call common#map_diff()
	else
		let cmd = perforce#setting#get('diff_tool','common').datas[0]

		if cmd =~ 'kdiff3'
			call system(cmd.' '.common#Get_kk(a:file).' '.common#Get_kk(a:file2).' -o '.common#Get_kk(a:file2))
		else
			" winmergeu
			call system(cmd.' '.common#Get_kk(a:file).' '.common#Get_kk(a:file2))
		endif
	endif

endfunction "}}}
