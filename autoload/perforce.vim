let $PFTMP = expand("~").'/vim/perforce_tmpfile'
let $PFHAVE = expand("~").'/vim/perforce_have'
let $PFDATA = expand("~").'/vim/perforce_data'
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
function! perforce#get_PFUSER() "{{{
	return g:pfuser
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
function! perforce#get_PFCLIENTPATH() "{{{
	return $PFCLIENTPATH
endfunction "}}}
"global
function! perforce#Get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#Get_kk(a:str).'...' : ''
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

	if 0
		exe 'Unite '.a:source.':'.perforce#Get_dd(expand("%:t"))
	else
		" スペース対策
		" [ ] p4_diffなどに修正が必要
		let tmp = a:source.':'.perforce#get_pathSrash(expand("%"))
		let tmp = substitute(tmp, ' ','\\ ', 'g')
		let tmp = 'Unite '.tmp
		echo tmp
		exe tmp
	endif

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
function! perforce#get_ClientName_from_client(str) "{{{
	return substitute(copy(a:str),'Client \(\S\+\).*','\1','g')
endfunction "}}}
function! perforce#get_path_from_have(str) "{{{
	let rtn = substitute(a:str,'\(.\{-}\)#\d\+ - \(\S*\)','\2','') 
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction "}}}
function! perforce#get_depot_from_have(str) "{{{
	return substitute(a:str,'\(.\{-}\)#\d\+ - \(.*\)','\1','') 
endfunction "}}}
function! perforce#get_paths_from_haves(strs) "{{{
	return map(a:strs,"perforce#get_path_from_have(v:val)")
endfunction "}}}
function! perforce#get_paths_from_fname(str) "{{{
	" ファイルを検索
	let outs = perforce#pfcmds('have','',perforce#Get_dd(a:str)) " # ファイル名の取得
	return perforce#get_paths_from_haves(outs)                   " # ヒットした場合
endfunction "}}}
function! perforce#get_path_from_depot(str) "{{{
	"let out = system('p4 have '.perforce#Get_kk(a:str))
	let outs = perforce#pfcmds('have','',perforce#Get_kk(a:str))
	let path = perforce#get_path_from_have(outs[0])
	return path
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref 直接データをもらう方法はないかな
	let path = substitute(str,'.* \d\d\d\d/\d\d/\d\d root \(.\{-}\) ''.*','\1','g')
	let path = perforce#get_pathSrash(path)
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

	" 最新 REV のファイルの取得 "{{{
	let outs = perforce#pfcmds('print','',' -q '.perforce#Get_kk(path))

	" エラーが発生したらファイルを検索して、すべてと比較 ( 再帰 )
	if outs[0] =~ "is not under client's root "
		call perforce#pfDiff_from_fname(path)
		return
	endif

	"tmpファイルの書き出し
	call writefile(outs,$PFTMP)
	"}}}

	" 改行が一致しないので保存し直す "{{{
	exe 'sp' $PFTMP
	set ff=dos
	wq
	"}}}

	" depotならpathに変換
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" 実際に比較 
	call perforce#pf_diff_tool($PFTMP,path)

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

	call perforce#LogFile(paths)
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

	"ChangeListの設定データを一時保存する
	let tmp = system('p4 change -o '.chnum)                          

	"コメントの編集
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" 新規作成の場合は、ファイルを含まない
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"一時ファイルの書き出し
	call writefile(split(tmp,'\n'),$PFTMP)

	"チェンジリストの作成
	return perforce#Get_cmds('more '.perforce#Get_kk($PFTMP).' | p4 change -i') 

endfunction "}}}
function! perforce#pfNewChange() "{{{
	let str = input('ChangeList Comment (new) : ')

	if str != ""
		" チェンジリストの作成 ( new )
		let outs = perforce#pfChange(str) 
		call perforce#LogFile(outs)
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

	let datas = split(system('p4 info'),'\n')
	for data in  datas
		if data =~ 'Client root: '
			let clpath = substitute(data, 'Client root: ','','')
			let clpath = perforce#get_pathSrash(clpath)
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
	call perforce#LogFile(outs)
	"}}}
endfunction "}}}
function! perforce#pfcmds(cmd,head,...) "{{{

	" common をコマンドに変更する
	let gcmds  = []
	let gcmd2s = []

	let gcmds += [a:head]

	if a:cmd  =~ 'client' || a:cmd =~ 'changes'	

		if perforce#get_pf_settings('user_changes_only', 'common')[0] == 1
			call add(gcmd2s, '-u '.perforce#get_PFUSER())
		endif 


		if perforce#get_pf_settings('show_max_flg', 'common')[0] == 1
			call add(gcmd2s, '-m '.perforce#get_pf_settings('show_max', 'common')[0])
		endif 

	endif

	if a:cmd  =~ 'changes'
		if perforce#get_pf_settings('client_changes_only', 'common')[0] == 1
			call add(gcmd2s, '-c '.perforce#get_PFCLIENTNAME())
		endif 
	endif

	let cmd = 'p4 '.join(gcmds).' '.a:cmd.' '.join(gcmd2s).' '.join(a:000)

	if perforce#get_pf_settings('show_cmd_flg', 'common')[0] == 1
		echo cmd
		call input("")
	endif

	return split(system(cmd),'\n')
endfunction "}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" 結果の出力を行う
	" @param[in]	str		表示する文字
	" @var
	" ********************************************************************************
	"
	if g:pf_settings.is_out_flg.common 
		if g:pf_settings.is_out_echo_flg.common
			echo a:str
		else
			call perforce#LogFile1('p4log', 0, a:str)
		endif
	endif

endfunction "}}}
" diff
function! perforce#getLineNumFromDiff(str,lnum,snum) "{{{
	" ********************************************************************************
	" 行番号を更新する
	" @param[in]	str		番号の更新を決める文字列
	" @param[in]	lnum	現在の番号
	" @param[in]	snum	初期値
	"
	" @retval       lnum	行番号
	" @retval       snum	初期値
	" ********************************************************************************
	let str = a:str
	let num = { 'lnum' : a:lnum , 'snum' : a:snum }

	let find = '[acd]'
	if str =~ '^\d\+'.find.'\d\+'
		let tmp = split(substitute(copy(str),find,',',''),',')
		let tmpnum = tmp[1] - 1
		let num.lnum = tmpnum
		let num.snum = tmpnum
	elseif str =~ '^\d\+,\d\+'.find.'\d\+'
		let tmp = split(substitute(copy(str),find,',',''),',')
		let tmpnum = tmp[2] - 1
		let num.lnum = tmpnum
		let num.snum = tmpnum
		" 最初の表示では、更新しない
	elseif str =~ '^[<>]' " # 番号の更新 
		let num.lnum = a:lnum + 1
	elseif str =~ '---'
		" 番号の初期化
		let num.lnum = a:snum
	endif
	return num
endfunction "}}}
function! perforce#getPathFromDiff(out,path) "{{{
	let path = a:path
	if a:out =~ '^===='
		let path = substitute(a:out,'^====.*#.\{-} - \(.*\) ====','\1','')
	endif 
	return path
endfunction "}}}
function! perforce#get_diff_path(outs) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let path = ''
	for out in outs
		let num = perforce#getLineNumFromDiff(out, num.lnum, num.snum)
		let lnum = num.lnum
		let path = perforce#getPathFromDiff(out,path)
		let candidates += [{
					\ 'word' : lnum.' : '.out,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ 'action__text' : substitute(out,'^[<>] ','',''),
					\ }]
	endfor
	return candidates
endfunction "}}}

" スペース対応
" ********************************************************************************
" スペース対応
" @param[in]	strs		'\ 'が入った文字列
" @retval       strs		'\ 'を削除した文字列
" ********************************************************************************
function!  perforce#get_trans_enspace(strs) "{{{
	let strs = a:strs
	return strs
endfunction "}}}

" ********************************************************************************
" 設定変数の初期化
" ********************************************************************************
function! perforce#init() "{{{

	if exists('g:pf_settings')
		return
	else
		" init
		let g:pf_settings = {}

		let g:pf_settings.user_changes_only = {
					\ 'common' : 1 ,
					\ 'description' : 'ユーザー名でフィルタ',
					\ }

		let g:pf_settings.client_changes_only = {
					\ 'common' : 1 ,
					\ 'description' : 'クライアントでフィルタ',
					\ }

		let g:pf_settings.is_out_flg = {
					\ 'common' : 1 ,
					\ 'description' : '実行結果を出力する',
					\ }

		let g:pf_settings.is_out_echo_flg = {
					\ 'common' : 1 ,
					\ 'description' : 'echo で実行結果を出力する',
					\ }

		let g:pf_settings.is_submit_flg = {
					\ 'common' : 1 ,
					\ 'description' : 'サブミットを許可',
					\ }

		let g:pf_settings.is_vimdiff_flg = {
					\ 'common' : 0 ,
					\ 'description' : 'vimdiff を使用する',
					\ }

		let g:pf_settings.ClientMove_recursive_flg = {
					\ 'common' : 0 ,
					\ 'description' : 'ClientMoveで再帰検索をするか',
					\ }

		let g:pf_settings.diff_tool = {
					\ 'common' : [ 1, 'WinMergeU', ],
					\ 'description' : 'Diff で使用するツール',
					\ }

		let g:pf_settings.ClientMove_defoult_root = {
					\ 'common' : [ 1, 'c:\tmp', 'c:\p4tmp', ],
					\ 'description' : 'ClientMoveの初期フォルダ',
					\ }

		let g:pf_settings.ports = {
					\ 'common' : [ 1, 'localhost:1818', ] ,
					\ 'description' : 'perforce port',
					\ }

		let g:pf_settings.is_quit = {
					\ 'common' : 0,
					\ 'description' : '実行後、閉じる',
					\ }

		let g:pf_settings.show_max = {
					\ 'common' : [ 100, ] , 
					\ 'description' : '表示するファイル数',
					\ }

		let g:pf_settings.show_max_flg = {
					\ 'common' : 0,
					\ 'description' : 'ファイル数の制限をする',
					\ }

		let g:pf_settings.show_cmd_flg = {
					\ 'common' : 1,
					\ 'description' : 'コマンドを表示する',
					\ }

		" 設定を読み込む
		call perforce#load($PFDATA)

		" クライアントデータの読み込み
		call perforce#get_client_data_from_info()

	endif
endfunction "}}}

" ********************************************************************************
" 設定ファイルの読み込み
" param[in]		file		設定ファイル名
" ********************************************************************************
function! perforce#load(file) "{{{

	" ファイルが見つからない場合は終了
	if filereadable(a:file) == 0
		echo 'Error - not fine '.a:file
		return
	endif

	" ファイルを読み込む
	let datas = readfile(a:file)

	" データを設定する
	for data in datas
		let tmp = split(data,"\t")
		exe 'let g:pf_settings["'.join(tmp[0:-2],'"]["').'"] = '.tmp[-1]

		" 型が変わるため、初期化が必要
	endfor

endfunction "}}}

" ********************************************************************************
" 設定ファイルを保存する
" param[in]		file		設定ファイル名
" ********************************************************************************
function! perforce#save(file) "{{{

	let datas = []

	let tmp  = ''
	for type in keys(g:pf_settings)
		for val in keys(g:pf_settings[type])
			if val != 'description'
				let datas += [type."\t".val."\t".string(g:pf_settings[type][val])."\r"]
			endif
		endfor
	endfor

	" 書き込む
	call writefile(datas, a:file)

endfunction "}}}

" ********************************************************************************
" 設定データを取得する
" @param[in]	type		pf_settings の設定の種類
" @param[in]	kind		common など, source の種類
" @retval		rtns 		取得データ
" ********************************************************************************
function! perforce#get_pf_settings(type, kind) "{{{
	" 設定がない場合は、共通を呼び出す
	let val     = get(g:pf_settings[a:type],a:kind,g:pf_settings[a:type].common)
	let valtype = type(val)

	if valtype == 3
		" リストの場合は、引数で取得する
		let rtns = <SID>get_pf_settings_from_lists(val)
	else
		let rtns = val
	endif

	return rtns
endfunction "}}}

" ********************************************************************************
" BIT 演算によって、データを取得する
" @param[in]	datas	{ bit, 文字列, ... } 
" @retval   	rtns 	リストを返す
" ********************************************************************************
function! s:get_pf_settings_from_lists(datas) "{{{

	" 有効なリストの取得 ( 一つ目は、フラグが入っているためスキップする )
	let nums = bit#get_nums_form_bit(a:datas[0]*2)

	" 有効な引数のみ返す
	return map(copy(nums), 'a:datas[v:val]')

endfunction "}}}

"okazu# からの移植
function! perforce#GetFileNameForUnite(args, context) "{{{
	" ファイル名の取得
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
function! perforce#Get_kk(str) "{{{
	"return substitute(a:str,'^\"?\(.*\)\"?','"\1"','')
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction "}}}
function! perforce#LogFile1(name, deleteFlg, ...) "{{{
	" ********************************************************************************
	" 新しいファイルを開いて書き込み禁止にする 
	" @param[in]	name		書き込み用tmpFileName
	" @param[in]	deleteFlg	初期化する
	" @param[in]	[...]		書き込むデータ
	" ********************************************************************************
	
	let @t = expand("%:p") " # mapで呼び出し用
	let name = a:name

	" 開いているか調べる
	let bnum = bufwinnr(name) 

	if bnum == -1
		" 画面内になければ新規作成
		exe 'sp ~/'.name
		%delete _          " # ファイル消去
		setl buftype=nofile " # 保存禁止
		setl fdm=manual
		call perforce#MyQuit()
	else
		" 表示しているなら切り替える
		exe bnum . 'wincmd w'
	endif

	" 初期化する
	if a:deleteFlg == 1
		%delete _
	endif

	" 書き込みデータがあるなら書き込む
	if exists("a:1") 
		call append(0,a:1)
	endif
	cal cursor(1,1) " # 一行目に移動する

endfunction "}}}
function! perforce#Map_diff() "{{{
	map <buffer> <up> [c
	map <buffer> <down> ]c
	map <buffer> <left> dp:<C-u>diffupdate<CR>
	map <buffer> <right> dn:<C-u>diffupdate<CR>
	map <buffer> <tab> <C-w><C-w>
endfunction "}}}
function! perforce#event_save_file(tmpfile,strs,func) "{{{
	" ********************************************************************************
	" ファイルを保存したときに、関数を実行します
	" @param[in]	tmpfile		保存するファイル名 ( 分割するファイル名 ) 
	" @param[in]	strs		初期の文章
	" @param[in]	func		実行する関数名
	" ********************************************************************************


	"画面設定
	exe 'vnew' a:tmpfile
    setlocal noswapfile bufhidden=hide buftype=acwrite

	"文の書き込み
	%delete _
	call append(0,a:strs)

	"一行目に移動
	cal cursor(1,1) 

	aug perforce_event_save_file "{{{
		au!
		exe 'autocmd BufWriteCmd <buffer> nested call '.a:func
	aug END "}}}

endfunction "}}}
function! perforce#get_pathEn(path) "{{{
	return substitute(a:path,'/','\','g') " # / マークに統一
endfunction "}}}
function! perforce#get_pathSrash(path) "{{{
	return substitute(a:path,'\','/','g') " # / マークに統一
endfunction "}}}
function! perforce#is_different(path,path2) "{{{
	" ********************************************************************************
	" 差分を調べる
	" @param[in]	path				比較ファイル1
	" @param[in]	path2				比較ファイル2
	" @retval		flg			TRUE	差分あり
	" 							FALSE	差分なし
	" ********************************************************************************
	let flg = 1
	let outs = perforce#Get_cmds('fc '.perforce#Get_kk(a:path).' '.perforce#Get_kk(a:path2))
	if outs[1] =~ '^FC: 相違点は検出されませんでした'
		let flg = 0
	endif
	return flg
endfunction "}}}
function! perforce#MyQuit() "{{{
	map <buffer> q :q<CR>
endfunction "}}}
function! perforce#Get_cmds(cmd) "{{{
	return split(system(a:cmd),'\n')
endfunction "}}}
