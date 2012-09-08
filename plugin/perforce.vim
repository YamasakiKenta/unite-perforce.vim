"[ ] jobs��client�Ɠ����悤�ɂ���
"[ ] job - fix , fixs 
"[ ] tags
"[ ] label

" �e���v���[�g�̍쐬���@
" p4 -p {port} -c {clname} client -o -t {cltmp} | p4 -p {port} -c {clname} client -i

"�擾�ł���l
"$PFCLIENTPATH " # �N���C�A���g�̃p�X
"$PFCLIENTNAME " # �N���C�A���g�̖��O

"com
" ********************************************************************************
" �w�肵��folder ��Merge���܂�
" @param[in]	�擾����Dir		...
"
" @var	g:pf_settings.ClientMove_recursive_flg.common
" 	Folder ���ċA�I�Ɍ������邩
"
" @var	g:ClientMove_defoult_root
" 	�������Ȃ��ꍇ�̎擾����Dir
" ********************************************************************************
command! -nargs=* ClientMove call s:clientMove(<q-args>)

" ********************************************************************************
" �t�@�C�����擾����
" @param[in ]	dirs			���[�g		
" @retval		datas.path		�t�@�C����
" @retval		datas.dir		���[�g
" ********************************************************************************
function! s:get_files_for_clientMove(dirs) "{{{	

	" �ċA����
	let recursive_flg = g:pf_settings.ClientMove_recursive_flg.common

	let datas = []
	let paths  = []
	for dir in a:dirs
		let dir = common#get_pathSrash(dir)

		if recursive_flg == 1
			let paths = split(glob(dir.'/**'),'\n')
		else
			let paths = split(glob(dir.'/*'),'\n')
		endif

		" �f�[�^�̓o�^
		for path in paths 
			call add( datas, {
						\ 'path' : common#get_pathSrash(path),
						\ 'dir'  : dir,
						\ })
		endfor
	endfor

	return datas
endfunction "}}}

" ********************************************************************************
" ��r����t�@�C���̎擾
" @param[in]	datas.path 		��������t�@�C��
" @param[in]	datas.dir 		��������t�@�C���̃��[�g
" @retval       merges.path1	��r����t�@�C�� ( c:\tmp ) 
" @retval       merges.path2	��r����t�@�C�� ( pfclient ) 
" ********************************************************************************
function! s:get_merge_files_for_clientMove(datas) "{{{
	let merges = []

	for data in a:datas
		let path = data.path
		let dir  = data.dir

		" �f�B���N�g���̏ꍇ�͔�r���Ȃ�
		if isdirectory(path) 
			continue
		endif

		" ���[�g����̃t�@�C�����̎擾
		let dir = substitute(dir, '/\?$', '/', '') 
		let file = substitute( path, dir, '', '')

		" \ -> /
		let file = common#get_pathSrash(file)

		" perforce ����擾����
		" ���O�����Ԃ�̂�h��
		let tmp_pfpaths = perforce#pfcmds('have','',('//...'.file))

		echo tmp_pfpaths

		" ���[�J�����ɕύX
		let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)")

		"p4 �ɂȂ���΁A��r���Ȃ� 
		"if exists('tmp_pfpaths[0]') && tmp_pfpaths[0] =~ 'file(s) not on client.'
		if tmp_pfpaths[0] =~ 'file(s) not on client.'
			continue
		endif

		for tmp_pfpath in tmp_pfpaths

			" / -> \
			let path       = common#get_pathEn(path)
			let tmp_pfpath = common#get_pathEn(tmp_pfpath)

			"�������Ȃ���΁A��r���Ȃ� 
			if common#is_different(path,tmp_pfpath) == 0
				continue
			endif

			echo '	>'. path.' - '. tmp_pfpath

			" ��r����t�@�C���̓o�^
			call add(merges, {
						\ "file1" : path,
						\ "file2" : tmp_pfpath,
						\ })
		endfor

	endfor 

	return merges
endfunction "}}}

" ********************************************************************************
" perforce ��̃t�@�C���ƃ}�[�W���� 
" @param[in]	...				root directorys 
" @retval		merges		unite �p�̈ꎞ�t�@�C��
" ********************************************************************************
function! s:clientMove(...) "{{{
	" Diff�c�[���̎擾
	let defoult_cmd = perforce#data#get('diff_tool', 'common').datas[0]

	" ���������蕶��������ꍇ�́A�������g�p����
	if a:0 > 0 && a:1 != ''
		let dirs = a:000
	else
		let dirs = perforce#data#get('ClientMove_defoult_root', 'common').datas
	endif 

	" root �̕\��
	echo ' Root : '.string(dirs)

	let datas = s:get_files_for_clientMove(dirs)
	
	" ��r����t�@�C���̎擾
	let merges = s:get_merge_files_for_clientMove(datas)

	"�}�[�W�m�F 
	let str = input("Merge ? [yes/no/unite/force]\n")
	echo '' 

	if str =~ 'f'
		" �����R�s�[
		let cmd = "copy"
	elseif str =~ 'y' 
		" �}�[�W����
		let cmd = defoult_cmd
	elseif str =~ 'u'
		call unite#start([insert(merges, 'p4_clientMove')])
		return
	else
		" �I��
		echo "...END...\n"
		return
	endif
	"
	"��r����
	for merge in merges 
		let file1 = merge.file1
		let file2 = merge.file2
		call system('p4 edit '.perforce#common#Get_kk(file2))
		call system(cmd.' '.perforce#common#Get_kk(file1).' '.perforce#common#Get_kk(file2))
		echo cmd.' '.perforce#common#Get_kk(file1).' '.perforce#common#Get_kk(file2)
	endfor
	"
endfunction "}}}

" ================================================================================
" command
" ================================================================================
command! -nargs=* MatomeDiffs call perforce#matomeDiffs(<args>)
command! GetClientName call perforce#get_client_data_from_info()
