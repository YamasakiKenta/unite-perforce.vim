let s:save_cpo = &cpo
set cpo&vim

function! perforce#get#lnum#from_diff_describe(str,lnum,snum) "{{{
	" ********************************************************************************
	" �s�ԍ����X�V����
	" @param[in]	str		�ԍ��̍X�V�����߂镶����
	" @param[in]	lnum	���݂̔ԍ�
	" @param[in]	snum	�����l
	"
	" @retval       lnum	�s�ԍ�
	" @retval       snum	�����l
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
		" �ŏ��̕\���ł́A�X�V���Ȃ�
	elseif str =~ '^[<>]' " # �ԍ��̍X�V 
		let num.lnum = a:lnum + 1
	elseif str =~ '---'
		" �ԍ��̏�����
		let num.lnum = a:snum
	endif
	return num
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
