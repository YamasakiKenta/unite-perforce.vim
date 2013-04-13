let s:save_cpo = &cpo
set cpo&vim

function! s:get_path_from_have(str) 
	let rtn = matchstr(a:str,'.\{-}#\d\+ - \zs.*')
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction

function! s:get_paths_from_haves(strs) 
	return map(a:strs,"s:get_path_from_have(v:val)")
endfunction

function! s:get_paths_from_fname(str) 
	" �t�@�C��������
	let outs = perforce#cmd#base('have','',perforce#get_dd(a:str)).outs " # �t�@�C�����̎擾
	return s:get_paths_from_haves(outs)                   " # �q�b�g�����ꍇ
endfunction

function! s:pfdiff_from_fname(fname) "{{{
	" ********************************************************************************
	" perforce�Ȃ�����t�@�C�������猟�����āA�S�Ĕ�r
	" @param[in]	fname	��r�������t�@�C����
	" ********************************************************************************
	"
	" �t�@�C�����݂̂̎�o��
	let file = fnamemodify(a:fname,":t")

	let paths = s:get_paths_from_fname(file)

	call perforce#LogFile(paths)
	for path in paths 
		call perforce#diff#main(path)
	endfor
endfunction
"}}}

function! perforce#diff#main(path) "{{{
	" ********************************************************************************
	" �t�@�C����TOOL���g�p���Ĕ�r���܂�
	" @param[in]	path		��r����p�X ( path or depot )
	" ********************************************************************************

	" �t�@�C���̔�r
	let path = a:path

	" �ŐV REV �̃t�@�C���̎擾 "{{{
	let outs = perforce#cmd#base('print','',' -q '.perforce#common#get_kk(path)).outs

	" �G���[������������t�@�C�����������āA���ׂĂƔ�r ( �ċA )
	if outs[0] =~ "is not under client's root "
		call s:pfdiff_from_fname(path)
		return
	endif

	"tmp�t�@�C���̏����o��
	call writefile(outs,g:perforce_tmp_file)
	"}}}

	" ���s����v���Ȃ��̂ŕۑ������� "{{{
	exe 'sp' g:perforce_tmp_file
	set ff=dos
	wq
	"}}}

	" depot�Ȃ�path�ɕϊ�
	if path =~ "^//depot.*"
		let path = perforce#get#path#from_depot(path)
	endif

	" ���ۂɔ�r 
	call s:pf_diff_tool(g:perforce_tmp_file,path)

endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
