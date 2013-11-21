let s:save_cpo = &cpo
set cpo&vim

function! perforce#util#get_files(...)
	return get(a:, 1, "") == "" ? [expand("%:p")] : a:000
endfunction

function! perforce#util#get_client_root(...) 
	return call(s:get_client_root, a:000)
endfunction 

function! perforce#util#get_client_root_from_client(...)
	return call(s:get_client_root_from_client, a:000)
endfunction

function! perforce#util#open_lines(...)
	return call(s:open_lines, a:000)
endfunction

function! perforce#util#log_file(...)
	return call(s:Common.LogFile, a:000)
endfunction

function! s:get_client_root(...) 
	if get(a:, '1', 0) != 0 || !exists('g:get_client_root_cache')
		" 失敗時の為に、初期化する
		let g:get_client_root_cache = ""
		let lines = split(system('p4 info'), "\n")
		let word = '^Client root: '
		for line in lines 
			if line =~ word
				let g:get_client_root_cache = matchstr(line, word.'\zs.*')
				break
			endif
		endfor
	endif
	return g:get_client_root_cache
endfunction

function! s:get_client_root_from_client(client) 
	let outs = filter(split(system('p4 '.a:client.' client -o'),"\n"), "v:val =~ '^Root:'")
	let rtn_d = {
				\ 'root'   : matchstr(outs[0], '^Root:\t\zs.*'),
				\ 'client' : matchstr(substitute(a:client, '\s\+', ' ', 'g'), '^\s*\zs\S.\{-}\ze\s*$')
				\ }
	return rtn_d
endfunction

function! s:open_lines(datas) 
	let datas = a:datas
	tabe

	" 最初の画面の更新
	call append(0, datas[0])
	call cursor(1,1)

	" 2画面目からは、分割する
	for lines in datas[1:]
		new
		call append(0, lines)
		call cursor(1,1)
	endfor	
endfunction

function! s:LogFile(name, deleteFlg, ...) 
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
		map <buffer> q :q<CR>
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

	return bufnr("%")
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
