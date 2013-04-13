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

function! s:pf_diff_tool(file,file2) "{{{
	if perforce#data#get('is_vimdiff_flg')
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call perforce#util#map_diff()
	else
		let cmd = perforce#data#get('diff_tool')

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
		else
			" winmergeu
			call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2))
		endif
	endif

endfunction
"}}}

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
	call writefile(outs,perforce#get_tmp_file())
	"}}}

	" ���s����v���Ȃ��̂ŕۑ�������
	exe 'sp' perforce#get_tmp_file()
	set ff=dos
	wq
	"

	" depot�Ȃ�path�ɕϊ�
	if path =~ "^//depot.*"
		let path = perforce#get#path#from_depot(path)
	endif

	" ���ۂɔ�r 
	call s:pf_diff_tool(perforce#get_tmp_file(),path)

endfunction
"}}}
"
function! perforce#diff#files(...) "{{{
	" ********************************************************************************
	" @param[in] �t�@�C����
	" ********************************************************************************
	let file_ = call('perforce#util#get_files', a:000)[0]
	return perforce#diff#main(file_)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
