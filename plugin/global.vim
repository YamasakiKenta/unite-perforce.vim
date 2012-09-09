" ********************************************************************************
" DIFF�c�[���̓o�^
" @param[in]	file	�ߋ��̃t�@�C��
" @param[in]	file2	���݂̃t�@�C��
" @var perforce#data#set(is_vimdiff_flg, common)
" 	TRUE 	vimdiff�Ŕ�r����
" @var g:pf_diff_tool
" 	DiffTool��
" ********************************************************************************
function! g:PerforceDiff(file,file2) "{{{
	if perforce#data#get('is_vimdiff_flg', 'common').datas[0]
		" �^�u�ŐV�����t�@�C�����J��
		exe 'tabe' a:file2
		exe 'vs' a:file

		" diff�̊J�n
		windo diffthis

		" �L�[�}�b�v�̓o�^
		call common#map_diff()
	else
		let cmd = perforce#data#get('diff_tool','common').datas[0]

		if cmd =~ 'kdiff3'
			call system(cmd.' '.perforce#common#Get_kk(a:file).' '.perforce#common#Get_kk(a:file2).' -o '.perforce#common#Get_kk(a:file2))
		else
			" winmergeu
			call system(cmd.' '.perforce#common#Get_kk(a:file).' '.perforce#common#Get_kk(a:file2))
		endif
	endif

endfunction "}}}
