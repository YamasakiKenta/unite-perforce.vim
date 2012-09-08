let $PFTMP = expand( exists('$PFTMP') ? $PFTMP : '~' )
let $PFTMPFILE  = $PFTMP.'\perforce\tmpfile'
let $PFHAVE = $PFTMP.'\perforce\have'
let $PFDATA = $PFTMP.'\perforce\data'
" ================================================================================
"@ 取得
" ================================================================================
function! perforce#get_filename_for_unite(args, context) "{{{
	" ファイル名の取得
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	let a:context.source__depots = perforce#get_depots(a:args, a:context.source__path)
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
"@set
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
"@get
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
function! perforce#get_PFCLIENTPATH() "{{{
	return $PFCLIENTPATH
endfunction "}}}
function! perforce#get_PFPORT() "{{{
	return $PFPORT
endfunction "}}}
function! perforce#get_PFUSER() "{{{
	return g:pfuser
endfunction "}}}
"@global
function! perforce#Get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#common#Get_kk(a:str).'...' : ''
endfunction "}}}
function! perforce#pf_diff_tool(file,file2) "{{{
	call g:PerforceDiff(a:file,a:file2)
endfunction "}}}
"@static
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
		let tmp = a:source.':'.common#get_pathSrash(expand("%"))
		let tmp = substitute(tmp, ' ','\\ ', 'g')
		let tmp = 'Unite '.tmp
		echo tmp
		exe tmp
	endif

endfunction "}}}

function! perforce#get_ClientName_from_client(str) "{{{
	return substitute(copy(a:str),'Client \(\S\+\).*','\1','g')
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref 直接データをもらう方法はないかな
	let path = substitute(str,'.* \d\d\d\d/\d\d/\d\d root \(.\{-}\) ''.*','\1','g')
	let path = common#get_pathSrash(path)
	return path
endfunction "}}}
function! perforce#pfFind(...) "{{{
	if a:0 == 0
		let str  = input('Find : ')
	else
		let str = a:1
	endif 
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
	let outs = perforce#pfcmds('print','',' -q '.perforce#common#Get_kk(path))

	" エラーが発生したらファイルを検索して、すべてと比較 ( 再帰 )
	if outs[0] =~ "is not under client's root "
		call perforce#pfDiff_from_fname(path)
		return
	endif

	"tmpファイルの書き出し
	call writefile(outs,$PFTMPFILE)
	"}}}

	" 改行が一致しないので保存し直す "{{{
	exe 'sp' $PFTMPFILE
	set ff=dos
	wq
	"}}}

	" depotならpathに変換
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" 実際に比較 
	call perforce#pf_diff_tool($PFTMPFILE,path)

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
	call writefile(split(tmp,'\n'),$PFTMPFILE)

	"チェンジリストの作成
	return perforce#common#Get_cmds('more '.perforce#common#Get_kk($PFTMPFILE).' | p4 change -i') 

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
			let clpath = common#get_pathSrash(clpath)
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
	" データの取得 {{{
	let outs = perforce#pfcmds('describe -ds','',a:chnum)

	" new file 用にここで初期化
	let datas = []

	" 作業中のファイル
	if outs[0] =~ '\*pending\*' || a:chnum == 'default'
		let files = perforce#pfcmds('opened','','-c '.a:chnum)
		call map(files, "perforce#get_depot_from_opened(v:val)")

		let outs = []
		for file in files 
			let list_tmps = perforce#pfcmds('diff -ds','',file)

			for list_tmp in list_tmps
				if list_tmp =~ '- file(s) not opened for edit.'
					let file_tmp = substitute(file, '.*[\/]','','')
					let path = perforce#get_path_from_depot(file)
					let datas += [{'files' : file_tmp, 'adds' : len(readfile(path)), 'changeds' : 0, 'deleteds' : 0, }]
				else
					let outs += [list_tmp]
				endif
			endfor
		endfor


	endif

	let find = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
	for out in outs
		if out =~ "===="
			let datas += [{'files' : substitute(out,'.*/\(.\{-}\)#.*','\1',''), 'adds' : 0, 'changeds' : 0, 'deleteds' : 0, }]
		elseif out =~ 'add'.find
			let datas[-1].adds = substitute(out,'add'.find,'\4','')
		elseif out =~ 'deleted'.find
			let datas[-1].deleteds = substitute(out,'deleted'.find,'\4','')
		elseif out =~ 'changed'.find
			let a = substitute(out,'changed'.find,'\3','')
			let b = substitute(out,'changed'.find,'\4','')
			let datas[-1].changeds = a > b ? a : b
		endif
	endfor
	"}}}
	"
	"データの出力 {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor
	call perforce#LogFile(outs)
	"}}}
endfunction "}}}
function! perforce#is_submitted_chnum(chnum) "{{{

endfunction "}}}
function! perforce#pfcmds(cmd,head,...) "{{{

	" common をコマンドに変更する
	let gcmds  = []
	let gcmd2s = []

	let gcmds += [a:head]

	if a:cmd  == 'clients' || a:cmd == 'changes'	

		if perforce#setting#get('user_changes_only', 'common').datas[0] == 1
			call add(gcmd2s, '-u '.perforce#get_PFUSER())
		endif 


		if perforce#setting#get('show_max_flg', 'common').datas[0] == 1
			call add(gcmd2s, '-m '.perforce#setting#get('show_max', 'common').datas[0])
		endif 

	endif

	if a:cmd  =~ 'changes'
		if perforce#setting#get('client_changes_only', 'common').datas[0] == 1
			call add(gcmd2s, '-c '.perforce#get_PFCLIENTNAME())
		endif 
	endif

	let cmd = 'p4 '.join(gcmds).' '.a:cmd.' '.join(gcmd2s).' '.join(a:000)

	if perforce#setting#get('show_cmd_flg', 'common').datas[0]
		echo cmd
		if perforce#setting#get('show_cmd_stop_flg', 'common').datas[0]
			call input("")
		endif
	endif

	let rtn = split(system(cmd),'\n')

	" 非表示にするコマンド
	if perforce#setting#get('filters_flg', 'common').datas
		let filters = perforce#setting#get('filters', 'common').datas
		let filter = join(filters, '\|')
		call filter(rtn, 'v:val !~ filter')
	endif

	return rtn
endfunction "}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" 結果の出力を行う
	" @param[in]	str		表示する文字
	" @var
	" ********************************************************************************
	"
	if perforce#setting#get('is_out_flg', 'common').datas[0]
		if perforce#setting#get('is_out_echo_flg', 'common').datas[0]
			echo a:str
		else
			call perforce#common#LogFile('p4log', 0, a:str)
		endif
	endif

endfunction "}}}
"@diff
function! perforce#get_lnum_from_diff(str,lnum,snum) "{{{
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
		let tmp = split(substitute(str,find,',',''),',')
		let tmpnum = tmp[1] - 1
		let num.lnum = tmpnum
		let num.snum = tmpnum
	elseif str =~ '^\d\+,\d\+'.find.'\d\+'
		let tmp = split(substitute(str,find,',',''),',')
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
" 
function! perforce#is_p4_have(str) "{{{
	" ********************************************************************************
	" クライアントにファイルがあるか調べる
	" @param[in]	str				ファイル名 , have の返り値
	" @retval       flg		TRUE 	存在する
	" @retval       flg		FLASE 	存在しない
	" ********************************************************************************
	let str = system('p4 have '.perforce#common#Get_kk(a:str))
	let flg = perforce#is_p4_have_from_have(str)
	return flg
endfunction "}}}
function! perforce#is_p4_have_from_have(str) "{{{

	if a:str =~ '- file(s) not on client.'
		let flg = 0
	else
		let flg = 1
	endif

	return flg

endfunction "}}}
function! perforce#get_trans_enspace(strs) "{{{
	" スペース対応
	" ********************************************************************************
	" スペース対応
	" @param[in]	strs		'\ 'が入った文字列
	" @retval       strs		'\ 'を削除した文字列
	" ********************************************************************************
	let strs = a:strs
	return strs
endfunction "}}}
function! perforce#init() "{{{
	call perforce#setting#init()
endfunction "}}}
"================================================================================
" 並び替え
"================================================================================
"@get_file
function! perforce#get_file_from_where(str) "{{{
	let file = a:str
	let file = substitute(file,'.*[\/]','','')
	let file = substitute(file,'\n','','g')
	return file
endfunction "}}}
"@get_depot(s)
function! perforce#get_depot_from_have(str) "{{{
	return matchstr(a:str,'.\{-}\ze#\d\+ - .*')
endfunction "}}}
function! perforce#get_depot_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # リビジョン番号の削除
endfunction "}}}
"@get_path(s)
function! perforce#get_path_from_where(str) "{{{
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction "}}}
function! perforce#get_path_from_have(str) "{{{
	let rtn = matchstr(a:str,'.\{-}#\d\+ - \zs.*')
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction "}}}
function! perforce#get_path_from_depot(str) "{{{
	let out = system('p4 where '.a:str)
	let path = perforce#get_path_from_where(out)
	return path
endfunction "}}}
function! perforce#get_paths_from_haves(strs) "{{{
	return map(a:strs,"perforce#get_path_from_have(v:val)")
endfunction "}}}
function! perforce#get_paths_from_fname(str) "{{{
	" ファイルを検索
	let outs = perforce#pfcmds('have','',perforce#Get_dd(a:str)) " # ファイル名の取得
	return perforce#get_paths_from_haves(outs)                   " # ヒットした場合
endfunction "}}}
"@p4_change
function! perforce#get_depots(args, path) "{{{
	" ********************************************************************************
	" depots を取得する
	" @param[in]	args	ファイル名
	" @param[in]	context
	" ********************************************************************************
	if len(a:args) > 0
		let depots = a:args
	else
		let depots = [a:path]
	endif
	return depots
endfunction "}}}
function! perforce#get_pfchanges(context,outs,kind) "{{{
	" ********************************************************************************
	" p4_changes Untie 用の 返り値を返す
	" @param(in)	context	
	" @param(in)	outs
	" @param(in)	kind	
	" ********************************************************************************
	let outs = a:outs
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : a:kind,
				\ 'action__chname' : '',
				\ 'action__chnum' : perforce#get_ChangeNum_from_changes(v:val),
				\ 'action__depots' : a:context.source__depots,
				\ }")


	return candidates
endfunction "}}}
"@source
function! perforce#get_source_file_from_path(path) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let path = a:path
	let lines = readfile(path)
	let candidates = []
	let lnum = 1
	for line in lines
		let candidates += [{
					\ 'word' : lnum.' : '.line,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ 'action__text' : line,
					\ }]
		let lnum += 1
	endfor
	return candidates
endfunction "}}}
function! perforce#get_source_diff_from_diff(outs) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let path = ''
	for out in outs
		let num = perforce#get_lnum_from_diff(out, num.lnum, num.snum)
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
