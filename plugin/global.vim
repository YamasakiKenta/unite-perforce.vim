" ********************************************************************************
" DIFF�c�[���̓o�^
" @param[in]	file	�ߋ��̃t�@�C��
" @param[in]	file2	���݂̃t�@�C��
" @var g:pf_settings.is_vimdiff_flg.common
" 	TRUE 	vimdiff�Ŕ�r����
" @var g:pf_diff_tool
" 	DiffTool��
" ********************************************************************************
function! g:PerforceDiff(file,file2) "{{{
	if perforce#get_pf_settings('is_vimdiff_flg', 'common').datas[0]
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call perforce#Map_diff()
	else
		let cmd = perforce#get_pf_settings('diff_tool','common').datas[0]

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#Get_kk(a:file).' '.perforce#Get_kk(a:file2).' -o '.perforce#Get_kk(a:file2))
		else
			" WinmergeU
			call system(cmd.' '.perforce#Get_kk(a:file).' '.perforce#Get_kk(a:file2))
		endif
	endif

endfunction "}}}
