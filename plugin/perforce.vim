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
command! -nargs=* ClientMove call <SID>clientMove(<q-args>)
function! s:clientMove(...) "{{{
	" ファイルの取得 "{{{
	let dirs = [get(a:,'2','c:\tmp')]
	let paths = []
	for dir in dirs
		let path = okazu#get_pathSrash(dir)
		let paths += split(glob(path.'/**'),'\n')
	endfor
	"}}}
	" ファイルの選別 "{{{
	" init "{{{
	let pfpaths = [] " # 比較対象ファイル ( P4のファイル ) 
	let i = 0
	"}}}
	for path in copy(paths) 
		let flg = 0 " # 比較しない : TRUE
		" ディレクトリなら、比較しない "{{{
		if isdirectory(path) 
			let flg = 1
		else 
			"}}}
			"p4 になければ、比較しない "{{{
			" ファイルの取得 "{{{
			let file = fnamemodify(path,":t") " # ファイル名のみにする
			let tmp_pfpaths = perforce#cmds('have '.perforce#Get_dd(file))             " # 複数ヒットした場合全部処理を行う
			let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)")      " # Localでのpathの取得
			let tmp_pfpath = tmp_pfpaths[0]
			"}}}
			if tmp_pfpath =~ 'file(s) not on client.'
				let flg = 1
			else 
				"}}}
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
				" 二つ目以降 "{{{
				for tmp_pfpath in tmp_pfpaths[1:]
					" 複数見つかった場合は、ファイル名をコピーする
					if okazu#is_different(path,tmp_pfpath) 
						call add(pfpaths,tmp_pfpath) " # 比較するファイルの登録
						call insert(paths,path,i) " # 二回目以降
						echo tmp_pfpath| " # 比較するファイルの表示
						let i+= 1
					endif
				endfor  
				"}}}
			endif " # p4になければ、比較しない
		endif " # ディレクトリなら、比較しない
		"}}}
		" リスト削除処理 "{{{
		" 二つ目以降は、追加処理のため削除処理を行う必要はない
		if flg 
			" 検索リストから削除する
			unlet paths[i]
		else
			let i += 1
		endif
		"}}}
	endfor "}}}
	"確認 "{{{

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
		echo '...END...'
		return
	endif 

	"}}}
	"比較する "{{{
	let i = 0
	for path in paths
		let file1 = path
		let file2 = pfpaths[i]
		call system('p4 edit '.okazu#Get_kk(file2))
		"call system('WinMergeU '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
		call system(cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
		let i+= 1 " # 更新
	endfor
	" }}}
endfunction "}}}
com! -nargs=* MatomeDiffs call perforce#matomeDiffs(<args>)
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
