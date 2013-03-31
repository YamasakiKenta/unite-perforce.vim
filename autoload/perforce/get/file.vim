let s:save_cpo = &cpo
set cpo&vim

function! s:get_lnum_from_diff_describe(str,lnum,snum) "{{{
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
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
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
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
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
