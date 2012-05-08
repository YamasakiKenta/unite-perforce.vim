"[ ] jobsをclientと同じようにする
"[ ] job - fix , fixs 
"[ ] tags
"[ ] label



"取得できる値
"$PFCLIENTPATH " # クライアントのパス
"$PFCLIENTNAME " # クライアントの名前

"com
" ********************************************************************************
" 指定したfolder をMergeします
" @param[in]	取得するDir		...
"
" @var	g:ClientMove_diffcmd
" 	Diff Tool
"
" @var	g:pf_settings.ClientMove_recursive_flg.common
" 	Folder を再帰的に検索するか
"
" @var	g:ClientMove_defoult_root
" 	引数がない場合の取得するDir
" ********************************************************************************
command! -nargs=* ClientMove call <SID>clientMove(<q-args>)

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
		let dir = okazu#get_pathSrash(dir)

		if recursive_flg == 1
			let paths = split(glob(dir.'/**'),'\n')
		else
			let paths = split(glob(dir.'/*'),'\n')
		endif

		" データの登録
		for path in paths 
			call add( datas, {
						\ 'path' : okazu#get_pathSrash(path),
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
		let file = okazu#get_pathSrash(file)

		" perforce から取得する
		let tmp_pfpaths = perforce#cmds('have '.perforce#Get_dd(file))

		" ローカル名に変更
		let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)")

		"p4 になければ、比較しない 
		if tmp_pfpaths[0] =~ 'file(s) not on client.'
			continue
		endif

		for tmp_pfpath in tmp_pfpaths

			" / -> \
			let path = okazu#get_pathEn(path)
			let tmp_pfpath = okazu#get_pathEn(tmp_pfpath)

			"差分がなければ、比較しない 
			if okazu#is_different(path,tmp_pfpath) == 0
				continue
			endif

			echo tmp_pfpath

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
" @retval		g:merges		unite 用の一時ファイル
" ********************************************************************************
function! s:clientMove(...) "{{{
	" Diffツールの取得
	let defoult_cmd = perforce#get_pf_settings('diff_tool', 'common')[0]

	" 検索するファイルの取得 
	" 引数がある場合は、引数を使用する
	if a:0 > 0
		let dirs = a:000
	else
		let dirs = perforce#get_pf_settings('ClientMove_defoult_root', 'common')
	endif 

	" root の表示
	echo ' Root : '.string(dirs)

	let datas = <SID>get_files_for_clientMove(dirs)

	" 比較するファイルの取得
	let merges = <SID>get_merge_files_for_clientMove(datas)

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
		let g:merges = merges
		call unite#start(['p4_clientMove'])
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
		call system('p4 edit '.okazu#Get_kk(file2))
		call system(cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
		echo cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2)
	endfor
	"
endfunction "}}}

command! -nargs=* MatomeDiffs call perforce#matomeDiffs(<args>)
"
"init
" 変数の定義 "{{{
if !exists("s:perforce_vim") 
	let $PFCLIENTNAME = ''
	let s:perforce_vim = 1 " # 初期読込完了
	let g:pfuser = ''
	let g:pf_use_defoult_client = 0
endif 
"}}}

function! s:pfinit() "{{{
	call perforce#get_client_data_from_info()
endfunction "}}}
call <SID>pfinit()
