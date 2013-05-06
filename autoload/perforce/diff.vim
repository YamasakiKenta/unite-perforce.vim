let s:save_cpo = &cpo
set cpo&vim

function! s:pf_diff_tool(file,file2) "{{{
	let cmd = perforce#data#get('g:unite_perforce_diff_tool')
	if cmd == 'vimdiff'
		" タブで新しいファイルを開く
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diffの開始
		windo diffthis

		" キーマップの登録
		call perforce#util#map_diff()
	elseif cmd =~ 'kdiff3'
		call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
	else
		" winmergeu
		call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2))
	endif

endfunction
"}}}

function! perforce#diff#main(path) "{{{
	" ********************************************************************************
	" ファイルをTOOLを使用して比較します
	" @param[in]	path		比較するパス ( path or depot )
	" ********************************************************************************

	" ファイルの比較
	let path = a:path

	" ファイル名があるか
	if len(path) == ''
		call perforce_2#echo_error("no file")
		return 
	endif


	" 最新 REV のファイルの取得
	let outs = perforce#cmd#files('print -q', [path], 1)[0].outs

	" ERROR
	if outs[0] =~ "is not under client's root "
		call perforce_2#echo_error("is not under client's root")
		return
	endif

	"tmpファイルの書き出し
	call writefile(outs, perforce#get_tmp_file())

	" 改行が一致しないので保存し直す
	exe 'sp' perforce#get_tmp_file()
	set ff=dos
	wq

	" depotならpathに変換
	if path =~ "^//depot.*"
		let path = perforce#get#path#from_depot(path)
	endif

	" 実際に比較 
	call s:pf_diff_tool(perforce#get_tmp_file(), path)

endfunction
"}}}
"
function! perforce#diff#file(...) "{{{
	" ********************************************************************************
	" @param[in] a:000 ファイル名
	" ********************************************************************************
	let file_ = call('perforce#util#get_files', a:000)[0]
	call perforce#diff#main(file_)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
