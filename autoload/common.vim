" ================================================================================
"okazu# からの移植
" ================================================================================
function! common#GetFileNameForUnite(args, context) "{{{
	" ファイル名の取得
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	let a:context.source__depots = perforce#get_depots(a:args, a:context.source__path)
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
function! common#Get_kk(str) "{{{
	"return substitute(a:str,'^\"?\(.*\)\"?','"\1"','')
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction "}}}
function! common#LogFile1(name, deleteFlg, ...) "{{{
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
		call common#MyQuit()
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
function! common#map_diff() "{{{
	map <buffer> <up> [c
	map <buffer> <down> ]c
	map <buffer> <left> do
	map <buffer> <right> do
	map <buffer> <tab> <C-w><C-w>
endfunction "}}}
function! common#event_save_file(tmpfile,strs,func) "{{{
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
function! common#get_pathEn(path) "{{{
	return substitute(a:path,'/','\','g') " # / マークに統一
endfunction "}}}
function! common#get_pathSrash(path) "{{{
	return substitute(a:path,'\','/','g') " # / マークに統一
endfunction "}}}
function! common#is_different(path,path2) "{{{
	" ********************************************************************************
	" 差分を調べる
	" @param[in]	path				比較ファイル1
	" @param[in]	path2				比較ファイル2
	" @retval		flg			TRUE	差分あり
	" 							FALSE	差分なし
	" ********************************************************************************
	let flg = 1
	let outs = common#Get_cmds('fc '.common#Get_kk(a:path).' '.common#Get_kk(a:path2))
	if outs[1] =~ '^FC: 相違点は検出されませんでした'
		let flg = 0
	endif
	return flg
endfunction "}}}
function! common#MyQuit() "{{{
	map <buffer> q :q<CR>
endfunction "}}}
function! common#Get_cmds(cmd) "{{{
	let rtns = split(system(a:cmd),'\n')
	return rtns
endfunction "}}}
