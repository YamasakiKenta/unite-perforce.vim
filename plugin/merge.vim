let s:_file  = expand("<sfile>")
let s:_debug = vital#of('unite-perforce.vim').import("Mind.Debug")
"
let g:perforce_merge_tool         = get(g:, 'perforce_merge_tool', 'winmergeu /S')
let g:perforce_merge_default_path = get(g:, 'perforce_merge_default_path', 'c:\tmp')

command! -nargs=? PfMerge call s:pf_merge(<q-args>)
function! s:pf_merge(...) "{{{
	" ********************************************************************************
	" 現在のクライアントと、マージします。
	" @param[in]	path	比較するファイル
	" @retval       NONE
	" ********************************************************************************
	let path = a:1 == "" ? g:perforce_merge_default_path : a:1
	call system(g:perforce_merge_tool.' "'.path.'" "'.$PFCLIENTPATH.'"')

endfunction
"}}}

if 0
function! s:get_merge_files_for_clientMove(datas) "{{{
	let merges = []

	for data in a:datas
		let path = data.path
		let dir  = data.dir

		" ディレクトリの場合は比較しない
		if isdirectory(path) 
			continue
		endif

		" ルートからのファイル名の取得
		let dir = substitute(dir, '/\?$', '/', '') 
		let file = substitute( path, dir, '', '')

		" \ -> /
		let file = perforce#common#get_pathSrash(file)

		" perforce から取得する
		" 名前がかぶるのを防ぐ
		let tmp_pfpaths = perforce#pfcmds('have','',('//...'.file)).outs

		exe s:_debug.exe_line()

		" ローカル名に変更
		let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)")

		"p4 になければ、比較しない 
		"if exists('tmp_pfpaths[0]') && tmp_pfpaths[0] =~ 'file(s) not on client.'
		if tmp_pfpaths[0] =~ 'file(s) not on client.'
			continue
		endif

		for tmp_pfpath in tmp_pfpaths

			" / -> \
			let path       = common#get_pathEn(path)
			let tmp_pfpath = common#get_pathEn(tmp_pfpath)

			"差分がなければ、比較しない 
			if common#is_different(path,tmp_pfpath) == 0
				continue
			endif

			exe s:_debug.exe_line()

			" 比較するファイルの登録
			call add(merges, {
						\ "file1" : path,
						\ "file2" : tmp_pfpath,
						\ })
		endfor

	endfor 

	return merges
endfunction "}}}
function! s:get_files_for_clientMove(dirs) "{{{	

	" 再帰検索
	let recursive_flg = perforce#data#set(ClientMove_recursive_flg, common)

	let datas = []
	let paths  = []
	for dir in a:dirs
		let dir = perforce#common#get_pathSrash(dir)

		if recursive_flg == 1
			let paths = split(glob(dir.'/**'),'\n')
		else
			let paths = split(glob(dir.'/*'),'\n')
		endif

		" データの登録
		for path in paths 
			call add( datas, {
						\ 'path' : perforce#common#get_pathSrash(path),
						\ 'dir'  : dir,
						\ })
		endfor
	endfor

	return datas
endfunction "}}}

command! -nargs=* ClientMove call s:clientMove(<q-args>)
function! s:clientMove(...) "{{{
	" Diffツールの取得
	let defoult_cmd = perforce#data#get('diff_tool')[0]

	" 引数があり文字がある場合は、引数を使用する
	if a:0 > 0 && a:1 != ''
		let dirs = a:000
	else
		let dirs = perforce#data#get('g:perforce_merge_default_path')
	endif 

	" root の表示
	echo string(dirs)

	let datas = s:get_files_for_clientMove(dirs)
	
	" 比較するファイルの取得
	let merges = s:get_merge_files_for_clientMove(datas)

	"マージ確認 
	let str = input("Merge ? [yes/no/unite/force]\n")

	if str =~ 'f'
		" 強制コピー
		let cmd = "copy"
	elseif str =~ 'y' 
		" マージ処理
		let cmd = defoult_cmd
	elseif str =~ 'u'
		call unite#start([insert(merges, 'p4_clientMove')])
		return
	else
		" 終了
		echo "...END..."
		return
	endif
	"
	"比較する
	for merge in merges 
		let file1 = merge.file1
		let file2 = merge.file2
		call system('p4 edit '.perforce#common#get_kk(file2))
		call system(cmd.' '.perforce#common#get_kk(file1).' '.perforce#common#get_kk(file2))
		echo perforce#common#get_kk(file1).' '.perforce#common#get_kk(file2)
	endfor
	"
endfunction "}}}
endif

