" ********************************************************************************
" DIFFツールの登録
" @param[in]	file	過去のファイル
" @param[in]	file2	現在のファイル
" @var perforce#data#set(is_vimdiff_flg, common)
" 	TRUE 	vimdiffで比較する
" @var g:pf_diff_tool
" 	DiffTool名
" ********************************************************************************
function! g:PerforceDiff(file,file2) "{{{
	if perforce#data#get('is_vimdiff_flg', 'common').datas[0]
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call common#map_diff()
	else
		let cmd = perforce#data#get('diff_tool','common').datas[0]

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#common#Get_kk(a:file).' '.perforce#common#Get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
		else
			" winmergeu
			call system(cmd.' '.perforce#common#Get_kk(a:file).' '.perforce#common#Get_kk(a:file2))
		endif
	endif

endfunction "}}}
