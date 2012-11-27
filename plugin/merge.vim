let s:_file  = expand("<sfile>")
let s:_debug = vital#of('unite-perforce.vim').import("Mind.Debug")
"
let g:perforce_merge_tool         = get(g:, 'perforce_merge_tool', 'winmergeu /S')
let g:perforce_merge_default_path = get(g:, 'perforce_merge_default_path', 'c:\tmp')

command! -nargs=? PfMerge call s:pf_merge(<q-args>)
function! s:pf_merge(...) "{{{
	" ********************************************************************************
	" ���݂̃N���C�A���g�ƁA�}�[�W���܂��B
	" @param[in]	path	��r����t�@�C��
	" @retval       NONE
	" ********************************************************************************
	let path = a:1 == "" ? g:perforce_merge_default_path : a:1
	call system(g:perforce_merge_tool.' "'.path.'" "'.$PFCLIENTPATH.'"')

endfunction
"}}}

if 0
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
		let file = perforce#common#get_pathSrash(file)

		" perforce ����擾����
		" ���O�����Ԃ�̂�h��
		let tmp_pfpaths = perforce#pfcmds('have','',('//...'.file)).outs

		exe s:_debug.exe_line()

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

			exe s:_debug.exe_line()

			" ��r����t�@�C���̓o�^
			call add(merges, {
						\ "file1" : path,
						\ "file2" : tmp_pfpath,
						\ })
		endfor

	endfor 

	return merges
endfunction "}}}
function! s:get_files_for_clientMove(dirs) "{{{	

	" �ċA����
	let recursive_flg = perforce#data#set(ClientMove_recursive_flg, common)

	let datas = []
	let paths  = []
	for dir in a:dirs
		let dir = perforce#common#get_pathSrash(dir)

		if recursive_flg == 1
			let paths = split(glob(dir.'/**'),'\n')
		else
			let paths = split(glob(dir.'/*'),'\n')
		endif

		" �f�[�^�̓o�^
		for path in paths 
			call add( datas, {
						\ 'path' : perforce#common#get_pathSrash(path),
						\ 'dir'  : dir,
						\ })
		endfor
	endfor

	return datas
endfunction "}}}

command! -nargs=* ClientMove call s:clientMove(<q-args>)
function! s:clientMove(...) "{{{
	" Diff�c�[���̎擾
	let defoult_cmd = perforce#data#get('diff_tool')[0]

	" ���������蕶��������ꍇ�́A�������g�p����
	if a:0 > 0 && a:1 != ''
		let dirs = a:000
	else
		let dirs = perforce#data#get('g:perforce_merge_default_path')
	endif 

	" root �̕\��
	echo string(dirs)

	let datas = s:get_files_for_clientMove(dirs)
	
	" ��r����t�@�C���̎擾
	let merges = s:get_merge_files_for_clientMove(datas)

	"�}�[�W�m�F 
	let str = input("Merge ? [yes/no/unite/force]\n")

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
		echo "...END..."
		return
	endif
	"
	"��r����
	for merge in merges 
		let file1 = merge.file1
		let file2 = merge.file2
		call system('p4 edit '.perforce#common#get_kk(file2))
		call system(cmd.' '.perforce#common#get_kk(file1).' '.perforce#common#get_kk(file2))
		echo perforce#common#get_kk(file1).' '.perforce#common#get_kk(file2)
	endfor
	"
endfunction "}}}
endif

