"[-] �`�F���W���X�g�����ԂŎ擾���� > InterFace���v�����Ȃ� > p4 change @2011/01/01,2011/02/01 > ���t���擾������@���l����
"[.] action__path�̍폜 ( diff, filelog �͏��� ) 
"[.] path only , opened(file)
"[.] depot only , 
"[.] path depot both , reopen
"[.] unite���J�n����R�}���h , annotate , diff , filelog
"[.] �������g�p����R�}���h , filelog , diff
"[.] file���K�v�ȃR�}���h , a_p4_diff_tool 
"[ ] jobs��client�Ɠ����悤�ɂ���
"[ ] job - fix , fixs 
"[ ] tags
"[ ] label



"�擾�ł���l
"$PFCLIENTPATH " # �N���C�A���g�̃p�X
"$PFCLIENTNAME " # �N���C�A���g�̖��O

"com
" ********************************************************************************
" �w�肵��folder ��Merge���܂�
" @param[in]	�擾����Dir		...
"
" @var	g:ClientMove_diffcmd
" 	Diff Tool
"
" @var	g:ClientMove_recursive_flg
" 	Folder ���ċA�I�Ɍ������邩
"
" @var	g:ClientMove_defoult_root
" 	�������Ȃ��ꍇ�̎擾����Dir
" ********************************************************************************
command! -nargs=* ClientMove call <SID>clientMove(<q-args>)

function! s:get_files_for_clientMove(dirs) "{{{	
" ********************************************************************************
" �t�@�C�����擾����
" @param[in ]	dirs			���[�g		
" @retval		datas.path		�t�@�C����
" @retval		datas.dir		���[�g
" ********************************************************************************

	" �ċA����
	let recursive_flg = g:ClientMove_recursive_flg

	let datas = []
	let paths  = []
	for dir in a:dirs
		let dir = okazu#get_pathSrash(dir)

		if recursive_flg == 1
			let paths = split(glob(dir.'/**'),'\n')
		else
			let paths = split(glob(dir.'/*'),'\n')
		endif

		" �f�[�^�̓o�^
		for path in paths 
			call add( datas, {
						\ 'path' : okazu#get_pathSrash(path),
						\ 'dir'  : dir,
						\ })
		endfor
	endfor

	return datas
endfunction "}}}

function! s:get_merge_files_for_clientMove(datas) "{{{
" ********************************************************************************
" ��r����t�@�C���̎擾
" @param[in]	datas.path 		��������t�@�C��
" @param[in]	datas.dir 		��������t�@�C���̃��[�g
" @retval       merges.path1	��r����t�@�C�� ( c:\tmp ) 
" @retval       merges.path2	��r����t�@�C�� ( pfclient ) 
" ********************************************************************************
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
		let file = okazu#get_pathSrash(file)

		" perforce ����擾����
		let tmp_pfpaths = perforce#cmds('have '.perforce#Get_dd(file))

		" ���[�J�����ɕύX
		let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)")

		"p4 �ɂȂ���΁A��r���Ȃ� 
		if tmp_pfpaths[0] =~ 'file(s) not on client.'
			continue
		endif

		for tmp_pfpath in tmp_pfpaths

			"�������Ȃ���΁A��r���Ȃ� 
			if okazu#is_different(path,tmp_pfpath) == 0
				continue
			endif

			echo tmp_pfpath

			" ��r����t�@�C���̓o�^
			call add(merges, {
						\ "file1" : path,
						\ "file2" : tmp_pfpath,
						\ })
		endfor

	endfor 

	return merges
endfunction "}}}

function! s:clientMove(...) "{{{
" ********************************************************************************
" perforce ��̃t�@�C���ƃ}�[�W���� 
" @param[in]	...				root directorys 
" @retval		g:merges		unite �p�̈ꎞ�t�@�C��
" @retval		g:defoult_cmd	unite �p�̈ꎞ�t�@�C��
" ********************************************************************************
	" Diff�c�[���̎擾
	let defoult_cmd = get(g:, 'ClientMove_diffcmd', 'WinMergeU')

	" ��������t�@�C���̎擾 
	let dirs = [get(a:,'2',g:ClientMove_defoult_root)]
	let datas = <SID>get_files_for_clientMove(dirs)

	" ��r����t�@�C���̎擾
	let merges = <SID>get_merge_files_for_clientMove(datas)

	" [ ] unite
	"
	"�}�[�W�m�F 
	let str = input("Merge ? [yes/no/unite/force]\n")
	echo '' 

	let cmd = defoult_cmd
	if str =~ 'f'
		" �����R�s�[
		let flg = 0
		let cmd = "copy"
	elseif str =~ 'y' 
		" �}�[�W����
		let flg = 0
		let cmd = defoult_cmd
	elseif str =~ 'u'
		let g:merges = merges
		let g:defoult_cmd = defoult_cmd
		call unite#start(['p4_clientMove'])
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
		call system('p4 edit '.okazu#Get_kk(file2))
		call system(cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
	endfor
	"
endfunction "}}}

command! -nargs=* MatomeDiffs call perforce#matomeDiffs(<args>)
"
"init
" �ϐ��̒�` "{{{
if !exists("s:perforce_vim") 
	let $PFCLIENTNAME = ''
	let s:perforce_vim = 1 " # �����Ǎ�����
	let g:pfuser = ''
	let g:pf_use_defoult_client = 0
endif 
"}}}

function! s:pfinit() "{{{
	call perforce#get_client_data_from_info()
endfunction "}}}
call <SID>pfinit()
