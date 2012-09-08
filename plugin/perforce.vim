"[ ] jobsをclientと同じようにする
"[ ] job - fix , fixs 
"[ ] tags
"[ ] label

" テンプレートの作成方法
" p4 -p {port} -c {clname} client -o -t {cltmp} | p4 -p {port} -c {clname} client -i

"取得できる値
"$PFCLIENTPATH " # クライアントのパス
"$PFCLIENTNAME " # クライアントの名前

"com
" ********************************************************************************
" 指定したfolder をMergeします
" @param[in]	取得するDir		...
"
" @var	g:pf_settings.ClientMove_recursive_flg.common
" 	Folder を再帰的に検索するか
"
" @var	g:ClientMove_defoult_root
" 	引数がない場合の取得するDir
" ********************************************************************************
command! -nargs=* ClientMove call s:clientMove(<q-args>)

" ********************************************************************************
" ファイルを取得する
" @param[in ]	dirs			ルート		
" @retval		datas.path		ファイル名
" @retval		datas.dir		ルート
" ********************************************************************************
function! s:get_files_for_clientMove(dirs) "{{{	

	" 再帰検索
	let recursive_flg = g:pf_settings.ClientMove_recursive_flg.common

	let datas = []
	let paths  = []
	for dir in a:dirs
		let dir = common#get_pathSrash(dir)

		if recursive_flg == 1
			let paths = split(glob(dir.'/**'),'\n')
		else
			let paths = split(glob(dir.'/*'),'\n')
		endif

		" データの登録
		for path in paths 
			call add( datas, {
						\ 'path' : common#get_pathSrash(path),
						\ 'dir'  : dir,
						\ })
		endfor
	endfor

	return datas
endfunction "}}}

" ********************************************************************************
" 比較するファイルの取得
" @param[in]	datas.path 		検索するファイル
" @param[in]	datas.dir 		検索するファイルのルート
" @retval       merges.path1	比較するファイル ( c:\tmp ) 
" @retval       merges.path2	比較するファイル ( pfclient ) 
" ********************************************************************************
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
		let file = common#get_pathSrash(file)

		" perforce から取得する
		" 名前がかぶるのを防ぐ
		let tmp_pfpaths = perforce#pfcmds('have','',('//...'.file))

		echo tmp_pfpaths

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

			echo '	>'. path.' - '. tmp_pfpath

			" 比較するファイルの登録
			call add(merges, {
						\ "file1" : path,
						\ "file2" : tmp_pfpath,
						\ })
		endfor

	endfor 

	return merges
endfunction "}}}

" ********************************************************************************
" perforce 上のファイルとマージする 
" @param[in]	...				root directorys 
" @retval		merges		unite 用の一時ファイル
" ********************************************************************************
function! s:clientMove(...) "{{{
	" Diffツールの取得
	let defoult_cmd = perforce#data#get('diff_tool', 'common').datas[0]

	" 引数があり文字がある場合は、引数を使用する
	if a:0 > 0 && a:1 != ''
		let dirs = a:000
	else
		let dirs = perforce#data#get('ClientMove_defoult_root', 'common').datas
	endif 

	" root の表示
	echo ' Root : '.string(dirs)

	let datas = s:get_files_for_clientMove(dirs)
	
	" 比較するファイルの取得
	let merges = s:get_merge_files_for_clientMove(datas)

	"マージ確認 
	let str = input("Merge ? [yes/no/unite/force]\n")
	echo '' 

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
		echo "...END...\n"
		return
	endif
	"
	"比較する
	for merge in merges 
		let file1 = merge.file1
		let file2 = merge.file2
		call system('p4 edit '.perforce#common#Get_kk(file2))
		call system(cmd.' '.perforce#common#Get_kk(file1).' '.perforce#common#Get_kk(file2))
		echo cmd.' '.perforce#common#Get_kk(file1).' '.perforce#common#Get_kk(file2)
	endfor
	"
endfunction "}}}

" ================================================================================
" command
" ================================================================================
command! -nargs=* MatomeDiffs call perforce#matomeDiffs(<args>)
command! GetClientName call perforce#get_client_data_from_info()
