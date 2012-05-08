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
	if g:pf_settings.is_vimdiff_flg.common
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call okazu#Map_diff()
	else
		call system(perforce#get_pf_settings('diff_tool','common')[0].' '.okazu#Get_kk(a:file).' '.okazu#Get_kk(a:file2))
	endif

endfunction "}}}
