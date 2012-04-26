"[-] チェンジリストを時間で取得する > InterFaceが思いつかない > p4 change @2011/01/01,2011/02/01 > 日付を取得する方法を考える
"[.] action__pathの削除 ( diff, filelog は除く ) 
"[.] path only , opened(file)
"[.] depot only , 
"[.] path depot both , reopen
"[.] uniteを開始するコマンド , annotate , diff , filelog
"[.] 引数を使用するコマンド , filelog , diff
"[.] fileが必要なコマンド , a_p4_diff_tool 
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
" @var	g:ClientMove_recursive_flg
" 	Folder を再帰的に検索するか
"
" @var	g:ClientMove_defoult_root
" 	引数がない場合の取得するDir
" ********************************************************************************
command! -nargs=* ClientMove call <SID>clientMove(<q-args>)

function! s:get_files_for_clientMove(dirs) "{{{	
" ********************************************************************************
" ファイルを取得する
" @param[in ]	dirs			ルート		
" @retval		datas.path		ファイル名
" @retval		datas.dir		ルート
" ********************************************************************************

	" 再帰検索
	let recursive_flg = g:ClientMove_recursive_flg

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

function! s:get_merge_files_for_clientMove(datas) "{{{
" ********************************************************************************
" 比較するファイルの取得
" @param[in]	datas.path 		検索するファイル
" @param[in]	datas.dir 		検索するファイルのルート
" @retval       merges.path1	比較するファイル ( c:\tmp ) 
" @retval       merges.path2	比較するファイル ( pfclient ) 
" ********************************************************************************
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

function! s:clientMove(...) "{{{
" ********************************************************************************
" perforce 上のファイルとマージする 
" @param[in]	...				root directorys 
" @retval		g:merges		unite 用の一時ファイル
" @retval		g:defoult_cmd	unite 用の一時ファイル
" ********************************************************************************
	" Diffツールの取得
	let defoult_cmd = get(g:, 'ClientMove_diffcmd', 'WinMergeU')

	" 検索するファイルの取得 
	let dirs = [get(a:,'2',g:ClientMove_defoult_root)]
	let datas = <SID>get_files_for_clientMove(dirs)

	" 比較するファイルの取得
	let merges = <SID>get_merge_files_for_clientMove(datas)

	" [ ] unite
	"
	"マージ確認 
	let str = input("Merge ? [yes/no/unite/force]\n")
	echo '' 

	let cmd = defoult_cmd
	if str =~ 'f'
		" 強制コピー
		let flg = 0
		let cmd = "copy"
	elseif str =~ 'y' 
		" マージ処理
		let flg = 0
		let cmd = defoult_cmd
	elseif str =~ 'u'
		let g:merges = merges
		let g:defoult_cmd = defoult_cmd
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
