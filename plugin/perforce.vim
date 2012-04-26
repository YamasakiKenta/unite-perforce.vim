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
function! s:clientMove(...) "{{{
	" Diff�c�[���̎擾
	let cmd = get(g:, 'ClientMove_diffcmd', 'WinMergeU')

	" �ċA�������邩 
	let recursive_flg = g:ClientMove_recursive_flg

	" init4
	let dirs = [get(a:,'2',g:ClientMove_defoult_root)]
	let tmps = []

	" �t�@�C���̎擾 "{{{
	let datas = []
	for dir in dirs

		" 
		let path = okazu#get_pathSrash(dir)
		if recursive_flg == 1
			let tmps = split(glob(path.'/**'),'\n')
		else
			let tmps = split(glob(path.'/*'),'\n')
		endif

		" �f�[�^�̓o�^
		for tmp in tmps 
			call add( datas, {
						\ 'path' : tmp,
						\ 'dir' : dir,
						\ })
		endfor
	endfor
	"}}}

	" �t�@�C���̑I�� "{{{
	let i = 0

	" todo  ������o�^����
	let pfpaths = [] " # ��r�Ώۃt�@�C�� ( P4�̃t�@�C�� ) 

	for data in copy(datas)

		echo data
		let path = data.path
		let dir  = data.dir

		" ��r���Ȃ��ꍇ�́ATRUE��ݒ肷��
		let flg = 0
		if isdirectory(path) 
			" �f�B���N�g���Ȃ�A��r���Ȃ� "{{{
			let flg = 1
			"}}}
		else 
			" �t�@�C�����̎擾 "{{{
			"
			" �Ō��\\��ǉ�����
			let dir = substitute(dir, '\', '\\\\', 'g')
			let dir = substitute(dir, '\\\?$', '\\\\', '') 

			" ���[�g�����
			let file = substitute( path, dir, '', '')

			" perforce ����擾����
			let tmp_pfpaths = perforce#cmds('have '.perforce#Get_dd(file))           " # �����q�b�g�����ꍇ�S���������s��
			let tmp_pfpaths = map(tmp_pfpaths, "perforce#get_path_from_have(v:val)") " # Local�ł�path�̎擾
			let tmp_pfpath = tmp_pfpaths[0]
			"}}}
			"
			if tmp_pfpath =~ 'file(s) not on client.'
				"p4 �ɂȂ���΁A��r���Ȃ� "{{{
				let flg = 1
				"}}}
			else 
				"�������Ȃ���΁A��r���Ȃ� "{{{
				" ��� "{{{
				if okazu#is_different(path,tmp_pfpath) 
					" ��r����t�@�C���̕\��
					echo tmp_pfpath

					call add(pfpaths,tmp_pfpath) " # ��r����t�@�C���̓o�^
				else
					" �������Ȃ���Δ�r���Ȃ�
					let flg = 1
				endif
				"}}}
				"
				" ��ڈȍ~ "{{{
				for tmp_pfpath in tmp_pfpaths[1:]
					" �������������ꍇ�́A�t�@�C�������R�s�[����
					if okazu#is_different(path,tmp_pfpath) 
						call add(pfpaths,tmp_pfpath) " # ��r����t�@�C���̓o�^

						call insert(datas, {
									\ 'path' : data.path,
									\ 'dir'  : data.dir,
									\ }, i) " # ���ڈȍ~ ��r����t�@�C����o�^����
						echo tmp_pfpath|" # ��r����t�@�C���̕\��
						let i += 1
					endif
				endfor  
				"}}}
			endif " # p4�ɂȂ���΁A��r���Ȃ�
		endif " # �f�B���N�g���Ȃ�A��r���Ȃ�
		"}}}
		"
		" ���X�g�폜���� "{{{
		" ��ڈȍ~�́A�ǉ������̂��ߍ폜�������s���K�v�͂Ȃ�
		if flg 
			" �������X�g����폜����
			unlet datas[i]
		else
			let i += 1
		endif
		"}}}
		"
	endfor "}}}

	"�}�[�W�m�F "{{{

	let str = input("Merge ? [yes/no/force]")
	echo '' 
	let flg = 1 " # �I��
	if str =~ 'f' " # �����R�s�[
		let flg = 0
		let cmd = "copy"
	elseif str =~ 'y' " # �}�[�W����
		let flg = 0
		let cmd = "WinMergeU"
	endif

	if flg 
		echo "...END...\n"
		return
	endif 

	"}}}
	"
	"��r���� "{{{
	let i = 0
	for data in datas 
		let path = data.path
		let file1 = path
		let file2 = pfpaths[i]
		call system('p4 edit '.okazu#Get_kk(file2))
		call system(cmd.' '.okazu#Get_kk(file1).' '.okazu#Get_kk(file2))
		let i+= 1 " # �X�V
	endfor
	" }}}
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
