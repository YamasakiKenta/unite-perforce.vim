function! g:PerforceDiff(file,file2) "{{{
	" ********************************************************************************
	" DIFF�c�[���̓o�^
	" @param[in]	file	�ߋ��̃t�@�C��
	" @param[in]	file2	���݂̃t�@�C��
	" ********************************************************************************
	if 1
		call system('WinMergeU '.okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	else
		"
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call okazu#Map_diff()
	endif

endfunction "}}}
