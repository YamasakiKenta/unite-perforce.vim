let s:save_cpo = &cpo
set cpo&vim

function! s:pf_diff_tool(file,file2) "{{{
	let cmd = perforce#data#get('g:unite_perforce_diff_tool')
	if cmd == 'vimdiff'
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call perforce#util#map_diff()
	elseif cmd =~ 'kdiff3'
		call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
	else
		" winmergeu
		call system(cmd.' '.perforce#common#get_kk(a:file).' '.perforce#common#get_kk(a:file2))
	endif

endfunction
"}}}

function! perforce#diff#main(path) "{{{
	" ********************************************************************************
	" �t�@�C����TOOL���g�p���Ĕ�r���܂�
	" @param[in]	path		��r����p�X ( path or depot )
	" ********************************************************************************

	" �t�@�C���̔�r
	let path = a:path

	" �t�@�C���������邩
	if len(path) == ''
		call perforce_2#echo_error("no file")
		return 
	endif


	" �ŐV REV �̃t�@�C���̎擾
	let outs = perforce#cmd#files('print -q', [path], 1)[0].outs

	" ERROR
	if outs[0] =~ "is not under client's root "
		call perforce_2#echo_error("is not under client's root")
		return
	endif

	"tmp�t�@�C���̏����o��
	call writefile(outs, perforce#get_tmp_file())

	" ���s����v���Ȃ��̂ŕۑ�������
	exe 'sp' perforce#get_tmp_file()
	set ff=dos
	wq

	" depot�Ȃ�path�ɕϊ�
	if path =~ "^//depot.*"
		let path = perforce#get#path#from_depot(path)
	endif

	" ���ۂɔ�r 
	call s:pf_diff_tool(perforce#get_tmp_file(), path)

endfunction
"}}}
"
function! perforce#diff#file(...) "{{{
	" ********************************************************************************
	" @param[in] a:000 �t�@�C����
	" ********************************************************************************
	let file_ = call('perforce#util#get_files', a:000)[0]
	call perforce#diff#main(file_)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
