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
function! s:clientMove(...) "{{{
	" Diffツールの取得
	let cmd = get(g:, 'ClientMove_diffcmd', 'WinMergeU')

	" 再帰検索するか 
	let recursive_flg = g:ClientMove_recursive_flg

	" init4
	let dirs = [get(a:,'2',g:ClientMove_defoult_root)]
	let tmps = []

	" ファイルの取得 "{{{
	let datas = []
	for dir in dirs

		" 
		let path = okazu#get_pathSrash(dir)
		if recursive_flg == 1
			let tmps = split(glob(path.'/**'),'\n')
		else
			let tmps = split(glob(path.'/*'),'\n')
		endif

		" データの登録
		for tmp in tmps 
			call add( datas, {
						\ 'path' : tmp,
						\ 'dir' : dir,
						\ })
		endfor
	endfor
	"}}}

	" ファイルの選別 "{{{
	let i = 0

	" todo  辞書を登録する
	let pfpaths = [] " # 比較対象ファイル ( P4のファイル ) 

	for data in copy(datas)

		echo data
		let path = data.path
		let dir  = data.dir

		" 比較しない場合は、TRUEを設定する
		let flg = 0
		if isdirectory(path) 
			" ディレクトリなら、比較しない "{{{
			let flg = 1
			"}}}
		else 
			" ファイル名の取得 "{{{
			"
			" 最後に\\を追加する
			let dir = substitute(dir, '\', '\\\\', 'g')
			let dir = substitute(dir, '\\\?$', '\\\\', '') 

			" ルートを削る
			let file = substitute( path, dir, '', '')

			" perforce から取得する
			let tmp_pfpaths = perforce#cmds('have '.perforce#Get_dd(file))           " # 複数ヒットした場合全部処理を行う
			let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)") " # Localでのpathの取得
			let tmp_pfpath = tmp_pfpaths[0]
			"}}}
			"
			if tmp_pfpath =~ 'file(s) not on client.'
				"p4 になければ、比較しない "{{{
				let flg = 1
				"}}}
			else 
				"差分がなければ、比較しない "{{{
				" 一つ目 "{{{
				if okazu#is_different(path,tmp_pfpath) 
					" 比較するファイルの表示
					echo tmp_pfpath

					call add(pfpaths,tmp_pfpath) " # 比較するファイルの登録
				else
					" 差分がなければ比較しない
					let flg = 1
				endif
				"}}}
				"
				" 二つ目以降 "{{{
				for tmp_pfpath in tmp_pfpaths[1:]
					" 複数見つかった場合は、ファイル名をコピーする
					if okazu#is_different(path,tmp_pfpath) 
						call add(pfpaths,tmp_pfpath) " # 比較するファイルの登録

						call insert(datas, {
									\ 'path' : data.path,
									\ 'dir'  : data.dir,
									\ }, i) " # 二回目以降 比較するファイルを登録する
						echo tmp_pfpath|" # 比較するファイルの表示
						let i += 1
					endif
				endfor  
				"}}}
			endif " # p4になければ、比較しない
		endif " # ディレクトリなら、比較しない
		"}}}
		"
		" リスト削除処理 "{{{
		" 二つ目以降は、追加処理のため削除処理を行う必要はない
		if flg 
			" 検索リストから削除する
			unlet datas[i]
		else
			let i += 1
		endif
		"}}}
		"
	endfor "}}}

	"マージ確認 "{{{

	let str = input("Merge ? [yes/no/force]")
	echo '' 
	let flg = 1 " # 終了
	if str =~ 'f' " # 強制コピー
		let flg = 0
		let cmd = "copy"
	elseif str =~ 'y' " # マージ処理
		let flg = 0
		let cmd = "WinMergeU"
	endif

	if flg 
		echo "...END...\n"
		return
	endif 

	"}}}
	"
	"比較する "{{{
	let i = 0
	for data in datas 
		let path = data.path
		let file1 = path
		let file2 = pfpaths[i]
		call system('p4 edit '.okazu#Get_kk(file2))
		call system(cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
		let i+= 1 " # 更新
	endfor
	" }}}
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
