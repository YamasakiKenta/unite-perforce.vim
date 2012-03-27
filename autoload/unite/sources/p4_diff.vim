function! unite#sources#p4_diff#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_diff',
			\ 'description' : '�t�@�C���̍����\��',
			\ }
function! s:get_diff_path(outs) "{{{
	" ********************************************************************************
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let lnum = 1
	let path = ''
	for out in outs
		let lnum = <SID>getLineNumFromDiff(out,lnum)
		let path = <SID>getPathFromDiff(out,path)
		let candidates += [{
					\ 'word' : lnum.' : '.out,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ }]
	endfor
	return candidates
endfunction "}}}
function! s:getLineNumFromDiff(str,lnum) "{{{
	let str = a:str
	let lnum = a:lnum
	let find = '[acd]'
	if str =~ '^\d\+'.find.'\d\+'
		let tmp = split(substitute(copy(str),find,',',''),',')
		let lnum = tmp[1] 
	elseif str =~ '^\d\+,\d\+'.find.'\d\+'
		let tmp = split(substitute(copy(str),find,',',''),',')
		let lnum = tmp[2]
	elseif str =~ '^>' " # �ԍ��̍X�V 
		let lnum = lnum + 1
	endif
	return lnum
endfunction "}}}
function! s:getPathFromDiff(out,path) "{{{
	let path = a:path
	if a:out =~ '^===='
		let path = substitute(a:out,'^====.*#.\{-} - \(.*\) ====','\1','')
	endif 
	return path
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" �������Ȃ��ꍇ�́A�󔒂�ݒ肷��
	let args = len(a:args) ? a:args : ['']

	let outs = []
	for arg in args
		let outs += perforce#cmds('diff '.okazu#Get_kk(arg))
	endfor

	return <SID>get_diff_path(outs) 
endfunction "}}}
