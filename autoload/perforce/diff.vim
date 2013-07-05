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
		call perforce#system(cmd.' '.perforce#get_kk(a:file).' '.perforce#get_kk(a:file2).' -o '.perforce#Get_kk(a:file2))
	else
		" winmergeu
		call perforce#system(cmd.' '.perforce#get_kk(a:file).' '.perforce#get_kk(a:file2))
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
		echoe "no file"
		return 
	endif


	" 最新 REV のファイルの取得
	let datas = perforce#cmd#use_port_clients('p4 print -q '.perforce#get_kk(path))
	let outs  = perforce#extend_dicts('outs', datas)

	" ERROR
	if !exists('outs[0]')
		echoe 'not find'
		return 
	elseif outs[0] =~ "is not under client's root "
		echoe "is not under client's root"
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
		let path = perforce#get#path#from_depot_with_client('', path)
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

if exists('s:save_cpo')
	let &cpo = s:save_cpo
	unlet s:save_cpo
else
	set cpo&
endif
