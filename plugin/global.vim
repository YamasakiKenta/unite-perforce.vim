function! g:PerforceDiff(file,file2) "{{{
	" ********************************************************************************
	" DIFF�c�[���̓o�^
	" @param[in]	file	�ߋ��̃t�@�C��
	" @param[in]	file2	���݂̃t�@�C��
	" @var g:pf_setting.bool.is_vimdiff_flg.value.common
	" 	TRUE 	vimdiff�Ŕ�r����
	" @var g:pf_diff_tool
	" 	DiffTool��
	"
	" ********************************************************************************
	if g:pf_setting.bool.is_vimdiff_flg.value.common
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call okazu#Map_diff()
	else
		call system(g:pf_setting.str.diff_tool.value.common.' '.okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	endif

endfunction "}}}
