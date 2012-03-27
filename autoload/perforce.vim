
let $PFTMP = expand("~")."/vim/tmpfile"
"set
function! perforce#set_PFCLIENTNAME(str) "{{{
	let $PFCLIENTNAME = a:str
endfunction "}}}
function! perforce#set_PFCLIENTPATH(str) "{{{
	let $PFCLIENTPATH = a:str
endfunction "}}}
function! perforce#set_PFPORT(str) "{{{
	let $PFPORT = a:str
endfunction "}}}
function! perforce#set_PFUSER(str) "{{{
	let g:pfuser = a:str
endfunction "}}}
"get
function! perforce#get_PFUSER_for_pfcmd(...) "{{{
	return g:pf_user_changes_only && g:pfuser !=# "" ? ' -u '.g:pfuser.' ' : ''
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
"[ ] 使用している場所の変更o
"コマンドで制御する
function! perforce#get_PFCLIENTNAME_for_pfcmd(...) "{{{
	return g:pf_client_changes_only && $PFCLIENTNAME !=# "" ? ' -c '.$PFCLIENTNAME.' ' : ''
endfunction "}}}
"global
function! perforce#Get_dd(str) "{{{
	return len(a:str) ? '//...'.okazu#Get_kk(a:str).'...' : ''
endfunction "}}}
function! perforce#pf_diff_tool(file,file2) "{{{
	call g:PerforceDiff(a:file,a:file2)
endfunction "}}}
"static
function! perforce#unite_args(source) "{{{
	"********************************************************************
	" 現在のファイル名を Unite に引数に渡します。
	" @param[in]	source	コマンド
	"********************************************************************

	"exe 'Unite '.a:source.':'.perforce#Get_dd(expand("%:t"))
	exe 'Unite '.a:source.':'.okazu#get_pathSrash(expand("%"))

endfunction "}}}
function! perforce#event_save_file(file,strs,func) "{{{
	" ********************************************************************************
	" ファイルを保存したときに、関数を実行します
	" @param[in]	file		保存するファイル名
	" @param[in]	strs		初期の文章
	" @param[in]	func		実行する関数名
	" ********************************************************************************
	"
	exe 'vsplit' a:file
	%delete _
	call append(0,a:strs)

	"一行目に移動
	cal cursor(1,1) 

	aug event_save_file
		au!
		exe 'autocmd BufWritePost <buffer> nested call '.a:func
	aug END


endfunction "}}}
function! perforce#pfLogFile(str) "{{{
	" ********************************************************************************
	" 結果の出力を行う
	" @param[in]	str		表示する文字
	" ********************************************************************************
	"
	if g:pf_is_out_flg
		call okazu#LogFile('p4log',a:str)
	endif

endfunction "}}}
function! perforce#get_ClientName_from_client(str) "{{{
	return substitute(copy(a:str),'Client \(\S\+\).*','\1','g')
endfunction "}}}
function! perforce#get_path_from_have(str) "{{{
	return substitute(a:str,'\(.\{-}\)#\d\+ - \(\S*\)','\2','') 
endfunction "}}}
function! perforce#get_depot_from_have(str) "{{{
	return substitute(a:str,'\(.\{-}\)#\d\+ - \(.*\)','\1','') 
endfunction "}}}
function! perforce#get_paths_from_haves(strs) "{{{
	return map(a:strs,"perforce#get_path_from_have(v:val)")
endfunction "}}}
function! perforce#get_paths_from_fname(str) "{{{
	" ファイルを検索
	let outs = perforce#cmds('have '.perforce#Get_dd(a:str)) " # ファイル名の取得
	return perforce#get_paths_from_haves(outs)                  " # ヒットした場合
endfunction "}}}
function! perforce#get_path_from_depot(str) "{{{
	"let out = system('p4 have '.okazu#Get_kk(a:str))
	let outs = perforce#cmds('have '.okazu#Get_kk(a:str))
	let path = perforce#get_path_from_have(outs[0])
	return path
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref 直接データをもらう方法はないかな
	let path = substitute(str,'.* \d\d\d\d/\d\d/\d\d root \(.\{-}\) ''.*','\1','g')
	let path = okazu#get_pathSrash(path)
	return path
endfunction "}}}
function! perforce#pfFind() "{{{
	let str  = input('Find : ')
	if str !=# ""
		call unite#start([insert(map(split(str),"perforce#Get_dd(v:val)"),'p4_have')])
	endif
endfunction "}}}
function! perforce#pfDiff(path) "{{{
	" ********************************************************************************
	" ファイルをTOOLを使用して比較します
	" @param[in]	path		比較するパス ( path or depot )
	" ********************************************************************************

	" ファイルの比較
	let path = a:path
	let tmpfile = $PFTMP

	" 最新 REV のファイルの取得 "{{{
	let outs = perforce#cmds('print -q '.okazu#Get_kk(path))

	" エラーが発生したらファイルを検索して、すべてと比較 ( 再帰 )
	if outs[0] =~ "is not under client's root "
		call perforce#pfDiff_from_fname(path)
		return
	endif

	"tmpファイルの書き出し
	call writefile(outs,tmpfile)
	"}}}

	" 改行が一致しないので保存し直す "{{{
	exe 'sp' tmpfile
	set ff=dos
	wq
	"}}}

	" depotならpathに変換
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" 実際に比較 
	call perforce#pf_diff_tool(tmpfile,path)

endfunction "}}}
function! perforce#pfDiff_from_fname(fname) "{{{
	" ********************************************************************************
	" perforceないからファイル名から検索して、全て比較
	" @param[in]	fname	比較したいファイル名
	" ********************************************************************************
	"
	" ファイル名のみの取出し
	let file = fnamemodify(a:fname,":t")

	let paths = perforce#get_paths_from_fname(file)

	call perforce#pfLogFile(paths)
	for path in paths 
		call perforce#pfDiff(path)
	endfor
endfunction "}}}

function! perforce#pfChange(str,...) "{{{
	"********************************************************************************
	" チェンジリストの作成
	" @param[in]	str		チェンジリストのコメント
	" @param[in]	...		編集するチェンジリスト番号
	"********************************************************************************
	"
	"チェンジ番号のセット ( 引数があるか )
	let chnum     = get(a:,'1','')

	"一時保存するファイルパス名
	let tmpfile = $PFTMP

	"ChangeListの設定データを一時保存する
	let tmp     = system('p4 change -o '.chnum)                          

	"コメントの編集
	let tmp     = substitute(tmp,'\nDescription:\zs.*>','\t'.a:str,'') 

	"一時ファイルの書き出し
	call writefile(split(tmp,'\n'),tmpfile)                            

	"チェンジリストの作成
	return okazu#Get_cmds('more '.okazu#Get_kk(tmpfile).' | p4 change -i') 

endfunction "}}}
function! perforce#pfNewChange() "{{{
	let str = input('ChangeList Comment (new) : ')

	if str != ""
		" チェンジリストの作成 ( new )
		let outs = perforce#pfChange(str) 
		call perforce#pfLogFile(outs)
	endif
endfunction "}}}
function! perforce#get_client_data_from_info() "{{{
	" ********************************************************************************
	" p4 info から情報を取得します
	" client root
	" client name
	" user name
	" ********************************************************************************
	let clname = ""
	let clpath = ""
	let user = ""
	for data in perforce#cmds('info') 
		if data =~ 'Client root: '
			let clpath = substitute(data, 'Client root: ','','')
			let clpath = okazu#get_pathSrash(clpath)
		elseif data =~ 'Client name: '
			let clname  = substitute(data, 'Client name: ','','')
		elseif data =~ 'User name: '
			let user  = substitute(data, 'User name: ','','')
		elseif data =~ 'error'
			break " # 取得に失敗したら終了
		endif
	endfor 

	" 設定する
	call perforce#set_PFCLIENTNAME(clname)
	call perforce#set_PFCLIENTPATH(clpath)
	call perforce#set_PFUSER(user)
endfunction "}}}

function! perforce#get_ChangeNum_from_changes(str) "{{{
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction "}}}
function! perforce#matomeDiffs(chnum) "{{{
	" 初期化 {{{
	let files = []
	let adds = []
	let deleteds = []
	let changeds = []
	let i = 0
	while i < 30
		let adds += [0]
		let deleteds += [0]
		let changeds += [0]
		let i += 1
	endwhile
	"}}}
	" データの取得 {{{
	let i = -1
	let find = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
	let outs = split(system('p4 describe -ds '.a:chnum),'\n')
	for out in outs
		if out =~ "===="
			let i += 1
			let files += [substitute(out,'.*/\(.\{-}\)#.*','\1','')]
		elseif out =~ 'add'.find
			let adds[i] = substitute(out,'add'.find,'\4','')
		elseif out =~ 'deleted'.find
			let deleteds[i] = substitute(out,'deleted'.find,'\4','')
		elseif out =~ 'changed'.find
			let a = substitute(out,'changed'.find,'\3','')
			let b = substitute(out,'changed'.find,'\4','')
			let changeds[i] = a > b ? a : b
		endif
	endfor
	"}}}
	"データの出力 {{{
	let i = 0
	let outs = []
	for l:file in files 
		let outs += [l:file."\t\t".adds[i]."\t".deleteds[i]."\t".changeds[i]]
		let i += 1
	endfor
	call perforce#pfLogFile(outs)
	"}}}
endfunction "}}}
function! perforce#cmds(cmd) "{{{
	" todo
	" [ ] clientNameをperforceに依存しないようにする
	
	if 0 
		if  g:pf_use_defoult_client == 1 " # 常に更新する
			call perforce#get_client_data_from_info() " # クライアントデータを更新する
		endif

		let filter = get(g:pf_filter, 'cmd', 0)" # フィルタの取得

		" 初期設定
		let client = ''
		let changes = ''
		let user = ''
		let port = ''

		if okazu#get_ronri_seki(filet ,g:G_PF_CLIENT)
			let client = '-c
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_PORT)
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_USER)
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_CHANGE)
		endif
	endif
	return split(system('p4 '.a:cmd),'\n')
endfunction "}}}
