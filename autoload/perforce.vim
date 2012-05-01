let $PFTMP = expand("~").'/vim/perforce_tmpfile'
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
function! perforce#get_PFUSER_for_pfcmd(...) "{{{
	return g:pf_setting.bool.user_changes_only.value.common && g:pfuser !=# "" ? ' -u '.g:pfuser.' ' : ''
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
"[ ] 使用している場所の変更o
"コマンドで制御する
function! perforce#get_PFCLIENTNAME_for_pfcmd(...) "{{{
	return g:pf_setting.bool.client_changes_only.value.common && $PFCLIENTNAME !=# "" ? ' -c '.$PFCLIENTNAME.' ' : ''
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

	if 0
		exe 'Unite '.a:source.':'.perforce#Get_dd(expand("%:t"))
	else
		" スペース対策
		" [ ] p4_diffなどに修正が必要
		let tmp = a:source.':'.okazu#get_pathSrash(expand("%"))
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

	" 最新 REV のファイルの取得 "{{{
	let outs = perforce#cmds('print -q '.okazu#Get_kk(path))

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
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\nFiles:','\t'.a:str,'') 

	" 新規作成の場合は、ファイルを含まない
	if chnum == "" | let tmp = substitute(tmp,'\nFile:\zs\_.*>','','') | endif

	"一時ファイルの書き出し
	call writefile(split(tmp,'\n'),$PFTMP)

	"チェンジリストの作成
	return okazu#Get_cmds('more '.okazu#Get_kk($PFTMP).' | p4 change -i') 

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
	call perforce#LogFile(outs)
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
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" 結果の出力を行う
	" @param[in]	str		表示する文字
	" @var
	" ********************************************************************************
	"
	if g:pf_setting.bool.is_out_flg.value.common 
		if g:pf_setting.bool.is_out_echo_flg.value.common
			echo a:str
		else
			call okazu#LogFile('p4log',a:str)
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

	if exists('g:pf_setting')
		return
	else
		" init
		let g:pf_setting = { 
					\ 'bool' : {},
					\ 'str'  : {},
					\ }

		" [] ファイルデータを読み込む

		let g:pf_setting.bool.user_changes_only = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : '名前でフィルタ',
					\ }

		let g:pf_setting.bool.client_changes_only = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : 'クライアントでフィルタ',
					\ }

		let g:pf_setting.bool.is_out_flg = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : '実行結果を出力する',
					\ }

		let g:pf_setting.bool.is_out_echo_flg = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : 'echo で実行結果を出力する',
					\ }

		let g:pf_setting.bool.is_submit_flg = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : 'サブミットを許可',
					\ }

		let g:pf_setting.bool.is_vimdiff_flg = {
					\ 'value' : { 'common' : 0 },
					\ 'description' : 'vimdiff を使用する',
					\ }

		let g:pf_setting.bool.ClientMove_recursive_flg = {
					\ 'value' : { 'common' : 0 },
					\ 'description' : 'ClientMoveで再帰検索をするか',
					\ }

		let g:pf_setting.str.diff_tool = {
					\ 'value' : { 'common' : 'WinMergeU' },
					\ 'description' : 'Diff で使用するツール',
					\ }

		let g:pf_setting.str.ClientMove_defoult_root = {
					\ 'value' : { 'common' : 'c:\tmp' },
					\ 'description' : 'ClientMoveの初期フォルダ',
					\ }

		let g:pf_setting.str.ports = {
					\ 'value' : { 'common' : ['localhost:1818'] },
					\ 'description' : 'perforce port',
					\ }

		" 設定を読み込む
		call perforce#load($PFDATA)

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
		exe 'let value = '.tmp[-1]

		let typestr = tmp[0]
		let valname = tmp[1]
		let param   = tmp[2]

		let g:pf_setting[typestr][valname].value[param] = value

		" 型が変わるため、初期化が必要
		unlet value
	endfor

endfunction "}}}

" ********************************************************************************
" 設定ファイルを保存する
" param[in]		file		設定ファイル名
" ********************************************************************************
function! perforce#save(file) "{{{

	let datas = []
	for type in keys(g:pf_setting)
		for val in keys(g:pf_setting[type])
			for param in keys(g:pf_setting[type][val].value)
				let datas += [type."\t".val."\t".param."\t".string(g:pf_setting[type][val].value[param])."\r"]
			endfor
		endfor
	endfor

	" 書き込む
	call writefile(datas, a:file)

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
