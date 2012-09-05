function! perforce#common#Get_cmds(cmd) "{{{
	return split(system(a:cmd),'\n')
endfunction "}}}
function! perforce#common#Get_kk(str) "{{{
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction "}}}
function! perforce#common#LogFile(name, deleteFlg, ...) "{{{
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
function! perforce#common#LogFile(name, deleteFlg, ...) "{{{
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
function! perforce#common#do_move()"{{{
endfunction"}}}
function! perforce#common#event_save_file()"{{{
endfunction"}}}
function! perforce#common#get_pathSrash(str)"{{{
	return substitute(a:str, '\\', '\/', 'g')
endfunction"}}}
function! perforce#common#map_diff() "{{{
	map <buffer> <A-up> [c
	map <buffer> <A-down> ]c
	map <buffer> <A-left>  :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <A-right> :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <tab> <C-w><C-w>|"

	echo 'vimwork'
endfunction "}}}
function! perforce#common#event_save_file(tmpfile,strs,func,args) "{{{
" ********************************************************************************
" ファイルを保存したときに、関数を実行します
" @param[in]	tmpfile		保存するファイル名 ( 分割するファイル名 ) 
" @param[in]	strs		初期の文章
" @param[in]	func		実行する関数名
" @param[in]	args		実行する関数名に渡す 引数
" ********************************************************************************

	"画面設定
	let bnum = bufwinnr(a:tmpfile) 

	if bnum == -1
		exe 'vnew' a:tmpfile
		setlocal noswapfile bufhidden=hide buftype=acwrite
	else
		" 表示しているなら切り替える
		exe bnum . 'wincmd w'
	endif

	"文の書き込み
	%delete _
	call append(0,a:strs)

	"一行目に移動
	call cursor(1,1) 

	call common#event_save_file_autocmd(a:func,a:args)

endfunction "}}}
function! perforce#common#event_save_file_autocmd(func,args) "{{{

	aug okazu_event_save_file
		au!
		exe 'autocmd BufWriteCmd <buffer> nested call '.a:func.'('.string(a:args).')'
	aug END

endfunction "}}}
