let s:save_cpo = &cpo
set cpo&vim

function! perforce#get#lnum#from_diff_describe(str,lnum,snum) "{{{
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
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
