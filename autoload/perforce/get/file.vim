let s:save_cpo = &cpo
set cpo&vim

function! s:get_lnum_from_diff_describe(str,lnum,snum) "{{{
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
function! s:get_path_from_diff(data_d, out) "{{{
	" ==== //depot/mind/unite-perforce.vim/autoload/perforce.vim#11 - C:\Users\yamasaki.mac\Dropbox\vim\mind\unite-perforce.vim\autoload\perforce.vim ====
	"
	let data_d = a:data_d
	if a:out =~ '^===='
		let data_d.path   = matchstr(a:out, '==== .*#\d* - \zs.*\ze ====')
		let data_d.depot  = matchstr(a:out, '==== \zs.*\ze#\d*')
		let data_d.revnum = matchstr(a:out, '==== .*#\zs\d*')
	endif 
	return data_d
endfunction "}}}

function! perforce#get#file#source_diff(outs) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let data_d = {
		\ 'path'  : '',
		\ 'depot' : '',
		\ }
	for out in outs
		let num = s:get_lnum_from_diff_describe(out, num.lnum, num.snum)
		let lnum = num.lnum
		let data_d = s:get_path_from_diff(data_d, out)
		let candidates += [{
					\ 'word' : lnum.' : '.out,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : data_d.path,
					\ 'action__text' : substitute(out,'^[<>] ','',''),
					\ }]
	endfor
	return candidates
endfunction "}}}
function! perforce#get#file#source_describe(outs) "{{{
	" ********************************************************************************
	" 差分の出力を、Uniteのjump_list化けする
	" @param[in]	outs		差分のデータ
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let data_d = {
		\ 'path'   : '',
		\ 'depot'  : '',
		\ 'revnum' : '',
		\ }
	for out in outs
		let num = s:get_lnum_from_diff_describe(out, num.lnum, num.snum)
		let lnum = num.lnum
		let data_d = s:get_path_from_diff(data_d, out)
		let candidates += [{
					\ 'word'           : lnum.' : '.out,
					\ 'kind'           : 'k_p4_filelog',
					\ 'action__line'   : lnum,
					\ 'action__depot'  : data_d.depot,
					\ 'action__revnum' : data_d.revnum,
					\ 'action__text'   : substitute(out,'^[<>] ','',''),
					\ }]
	endfor
	return candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
