function! g:PerforceDiff(file,file2) "{{{
	" ********************************************************************************
	" DIFF�c�[���̓o�^
	" @param[in]	file	�ߋ��̃t�@�C��
	" @param[in]	file2	���݂̃t�@�C��
	" @var g:pf_setting.bool.is_vimdiff_flg.value
	" 	TRUE 	vimdiff�Ŕ�r����
	" @var g:pf_diff_tool
	" 	DiffTool��
	"
	" ********************************************************************************
	let g:tmp = ""
	if g:pf_setting.bool.is_vimdiff_flg.value
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call okazu#Map_diff()
	else
		call system(g:pf_diff_tool." ".okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	endif

endfunction "}}}
