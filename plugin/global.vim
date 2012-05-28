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
	if perforce#get_pf_settings('is_vimdiff_flg', 'common').datas[0]
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call perforce#Map_diff()
	else
		let cmd = perforce#get_pf_settings('diff_tool','common').datas[0]

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#Get_kk(a:file).' '.perforce#Get_kk(a:file2).' -o '.perforce#Get_kk(a:file2))
		else
			" WinmergeU
			call system(cmd.' '.perforce#Get_kk(a:file).' '.perforce#Get_kk(a:file2))
		endif
	endif

endfunction "}}}
