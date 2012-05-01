let $PFTMP = expand("~").'/vim/perforce_tmpfile'
let $PFDATA = expand("~").'/vim/perforce_data'
"set
function! perforce#set_PFCLIENTNAME(str) "{{{
	let $PFCLIENTNAME = a:str
endfunction "}}}
function! perforce#set_PFCLIENTPATH(str) "{{{
	let $PFCLIENTPATH = a:str
endfunction "}}}
function! perforce#set_PFPORT(str) "{{{
	let $PFPORT = a:str
endfunction "}}}
function! perforce#set_PFUSER(str) "{{{
	let g:pfuser = a:str
endfunction "}}}
"get
function! perforce#get_PFUSER_for_pfcmd(...) "{{{
	return g:pf_setting.bool.user_changes_only.value.common && g:pfuser !=# "" ? ' -u '.g:pfuser.' ' : ''
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
"[ ] �g�p���Ă���ꏊ�̕ύXo
"�R�}���h�Ő��䂷��
function! perforce#get_PFCLIENTNAME_for_pfcmd(...) "{{{
	return g:pf_setting.bool.client_changes_only.value.common && $PFCLIENTNAME !=# "" ? ' -c '.$PFCLIENTNAME.' ' : ''
endfunction "}}}
"global
function! perforce#Get_dd(str) "{{{
	return len(a:str) ? '//...'.okazu#Get_kk(a:str).'...' : ''
endfunction "}}}
function! perforce#pf_diff_tool(file,file2) "{{{
	call g:PerforceDiff(a:file,a:file2)
endfunction "}}}
"static
function! perforce#unite_args(source) "{{{
	"********************************************************************
	" ���݂̃t�@�C������ Unite �Ɉ����ɓn���܂��B
	" @param[in]	source	�R�}���h
	"********************************************************************

	if 0
		exe 'Unite '.a:source.':'.perforce#Get_dd(expand("%:t"))
	else
		" �X�y�[�X�΍�
		" [ ] p4_diff�ȂǂɏC�����K�v
		let tmp = a:source.':'.okazu#get_pathSrash(expand("%"))
		let tmp = substitute(tmp, ' ','\\ ', 'g')
		let tmp = 'Unite '.tmp
		echo tmp
		exe tmp
	endif

endfunction "}}}
function! perforce#event_save_file(file,strs,func) "{{{
	" ********************************************************************************
	" �t�@�C����ۑ������Ƃ��ɁA�֐������s���܂�
	" @param[in]	file		�ۑ�����t�@�C����
	" @param[in]	strs		�����̕���
	" @param[in]	func		���s����֐���
	" ********************************************************************************
	"
	exe 'vsplit' a:file
	%delete _
	call append(0,a:strs)

	"��s�ڂɈړ�
	cal cursor(1,1) 

	aug event_save_file
		au!
		exe 'autocmd BufWritePost <buffer> nested call '.a:func
	aug END


endfunction "}}}
function! perforce#get_ClientName_from_client(str) "{{{
	return substitute(copy(a:str),'Client \(\S\+\).*','\1','g')
endfunction "}}}
function! perforce#get_path_from_have(str) "{{{
	let rtn = substitute(a:str,'\(.\{-}\)#\d\+ - \(\S*\)','\2','') 
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction "}}}
function! perforce#get_depot_from_have(str) "{{{
	return substitute(a:str,'\(.\{-}\)#\d\+ - \(.*\)','\1','') 
endfunction "}}}
function! perforce#get_paths_from_haves(strs) "{{{
	return map(a:strs,"perforce#get_path_from_have(v:val)")
endfunction "}}}
function! perforce#get_paths_from_fname(str) "{{{
	" �t�@�C��������
	let outs = perforce#cmds('have '.perforce#Get_dd(a:str)) " # �t�@�C�����̎擾
	return perforce#get_paths_from_haves(outs)                  " # �q�b�g�����ꍇ
endfunction "}}}
function! perforce#get_path_from_depot(str) "{{{
	"let out = system('p4 have '.okazu#Get_kk(a:str))
	let outs = perforce#cmds('have '.okazu#Get_kk(a:str))
	let path = perforce#get_path_from_have(outs[0])
	return path
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref ���ڃf�[�^�����炤���@�͂Ȃ�����
	let path = substitute(str,'.* \d\d\d\d/\d\d/\d\d root \(.\{-}\) ''.*','\1','g')
	let path = okazu#get_pathSrash(path)
	return path
endfunction "}}}
function! perforce#pfFind() "{{{
	let str  = input('Find : ')
	if str !=# ""
		call unite#start([insert(map(split(str),"perforce#Get_dd(v:val)"),'p4_have')])
	endif
endfunction "}}}
function! perforce#pfDiff(path) "{{{
	" ********************************************************************************
	" �t�@�C����TOOL���g�p���Ĕ�r���܂�
	" @param[in]	path		��r����p�X ( path or depot )
	" ********************************************************************************

	" �t�@�C���̔�r
	let path = a:path

	" �ŐV REV �̃t�@�C���̎擾 "{{{
	let outs = perforce#cmds('print -q '.okazu#Get_kk(path))

	" �G���[������������t�@�C�����������āA���ׂĂƔ�r ( �ċA )
	if outs[0] =~ "is not under client's root "
		call perforce#pfDiff_from_fname(path)
		return
	endif

	"tmp�t�@�C���̏����o��
	call writefile(outs,$PFTMP)
	"}}}

	" ���s����v���Ȃ��̂ŕۑ������� "{{{
	exe 'sp' $PFTMP
	set ff=dos
	wq
	"}}}

	" depot�Ȃ�path�ɕϊ�
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" ���ۂɔ�r 
	call perforce#pf_diff_tool($PFTMP,path)

endfunction "}}}
function! perforce#pfDiff_from_fname(fname) "{{{
	" ********************************************************************************
	" perforce�Ȃ�����t�@�C�������猟�����āA�S�Ĕ�r
	" @param[in]	fname	��r�������t�@�C����
	" ********************************************************************************
	"
	" �t�@�C�����݂̂̎�o��
	let file = fnamemodify(a:fname,":t")

	let paths = perforce#get_paths_from_fname(file)

	call perforce#LogFile(paths)
	for path in paths 
		call perforce#pfDiff(path)
	endfor
endfunction "}}}

function! perforce#pfChange(str,...) "{{{
	"********************************************************************************
	" �`�F���W���X�g�̍쐬
	" @param[in]	str		�`�F���W���X�g�̃R�����g
	" @param[in]	...		�ҏW����`�F���W���X�g�ԍ�
	"********************************************************************************
	"
	"�`�F���W�ԍ��̃Z�b�g ( ���������邩 )
	let chnum     = get(a:,'1','')

	"ChangeList�̐ݒ�f�[�^���ꎞ�ۑ�����
	let tmp = system('p4 change -o '.chnum)                          

	"�R�����g�̕ҏW
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\nFiles:','\t'.a:str,'') 

	" �V�K�쐬�̏ꍇ�́A�t�@�C�����܂܂Ȃ�
	if chnum == "" | let tmp = substitute(tmp,'\nFile:\zs\_.*>','','') | endif

	"�ꎞ�t�@�C���̏����o��
	call writefile(split(tmp,'\n'),$PFTMP)

	"�`�F���W���X�g�̍쐬
	return okazu#Get_cmds('more '.okazu#Get_kk($PFTMP).' | p4 change -i') 

endfunction "}}}
function! perforce#pfNewChange() "{{{
	let str = input('ChangeList Comment (new) : ')

	if str != ""
		" �`�F���W���X�g�̍쐬 ( new )
		let outs = perforce#pfChange(str) 
		call perforce#LogFile(outs)
	endif
endfunction "}}}
function! perforce#get_client_data_from_info() "{{{
	" ********************************************************************************
	" p4 info ��������擾���܂�
	" client root
	" client name
	" user name
	" ********************************************************************************
	let clname = ""
	let clpath = ""
	let user = ""
	for data in perforce#cmds('info') 
		if data =~ 'Client root: '
			let clpath = substitute(data, 'Client root: ','','')
			let clpath = okazu#get_pathSrash(clpath)
		elseif data =~ 'Client name: '
			let clname  = substitute(data, 'Client name: ','','')
		elseif data =~ 'User name: '
			let user  = substitute(data, 'User name: ','','')
		elseif data =~ 'error'
			break " # �擾�Ɏ��s������I��
		endif
	endfor 

	" �ݒ肷��
	call perforce#set_PFCLIENTNAME(clname)
	call perforce#set_PFCLIENTPATH(clpath)
	call perforce#set_PFUSER(user)
endfunction "}}}

function! perforce#get_ChangeNum_from_changes(str) "{{{
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction "}}}
function! perforce#matomeDiffs(chnum) "{{{
	" ������ {{{
	let files = []
	let adds = []
	let deleteds = []
	let changeds = []
	let i = 0
	while i < 30
		let adds += [0]
		let deleteds += [0]
		let changeds += [0]
		let i += 1
	endwhile
	"}}}
	" �f�[�^�̎擾 {{{
	let i = -1
	let find = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
	let outs = split(system('p4 describe -ds '.a:chnum),'\n')
	for out in outs
		if out =~ "===="
			let i += 1
			let files += [substitute(out,'.*/\(.\{-}\)#.*','\1','')]
		elseif out =~ 'add'.find
			let adds[i] = substitute(out,'add'.find,'\4','')
		elseif out =~ 'deleted'.find
			let deleteds[i] = substitute(out,'deleted'.find,'\4','')
		elseif out =~ 'changed'.find
			let a = substitute(out,'changed'.find,'\3','')
			let b = substitute(out,'changed'.find,'\4','')
			let changeds[i] = a > b ? a : b
		endif
	endfor
	"}}}
	"�f�[�^�̏o�� {{{
	let i = 0
	let outs = []
	for l:file in files 
		let outs += [l:file."\t\t".adds[i]."\t".deleteds[i]."\t".changeds[i]]
		let i += 1
	endfor
	call perforce#LogFile(outs)
	"}}}
endfunction "}}}
function! perforce#cmds(cmd) "{{{
	" todo
	" [ ] clientName��perforce�Ɉˑ����Ȃ��悤�ɂ���

	if 0 
		if  g:pf_use_defoult_client == 1 " # ��ɍX�V����
			call perforce#get_client_data_from_info() " # �N���C�A���g�f�[�^���X�V����
		endif

		let filter = get(g:pf_filter, 'cmd', 0)" # �t�B���^�̎擾

		" �����ݒ�
		let client = ''
		let changes = ''
		let user = ''
		let port = ''

		if okazu#get_ronri_seki(filet ,g:G_PF_CLIENT)
			let client = '-c
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_PORT)
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_USER)
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_CHANGE)
		endif
	endif
	return split(system('p4 '.a:cmd),'\n')
endfunction "}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" ���ʂ̏o�͂��s��
	" @param[in]	str		�\�����镶��
	" @var
	" ********************************************************************************
	"
	if g:pf_setting.bool.is_out_flg.value.common 
		if g:pf_setting.bool.is_out_echo_flg.value.common
			echo a:str
		else
			call okazu#LogFile('p4log',a:str)
		endif
	endif

endfunction "}}}
" diff
function! perforce#getLineNumFromDiff(str,lnum,snum) "{{{
	" ********************************************************************************
	" �s�ԍ����X�V����
	" @param[in]	str		�ԍ��̍X�V�����߂镶����
	" @param[in]	lnum	���݂̔ԍ�
	" @param[in]	snum	�����l
	"
	" @retval       lnum	�s�ԍ�
	" @retval       snum	�����l
	" ********************************************************************************
	let str = a:str
	let num = { 'lnum' : a:lnum , 'snum' : a:snum }

	let find = '[acd]'
	if str =~ '^\d\+'.find.'\d\+'
		let tmp = split(substitute(copy(str),find,',',''),',')
		let tmpnum = tmp[1] - 1
		let num.lnum = tmpnum
		let num.snum = tmpnum
	elseif str =~ '^\d\+,\d\+'.find.'\d\+'
		let tmp = split(substitute(copy(str),find,',',''),',')
		let tmpnum = tmp[2] - 1
		let num.lnum = tmpnum
		let num.snum = tmpnum
		" �ŏ��̕\���ł́A�X�V���Ȃ�
	elseif str =~ '^[<>]' " # �ԍ��̍X�V 
		let num.lnum = a:lnum + 1
	elseif str =~ '---'
		" �ԍ��̏�����
		let num.lnum = a:snum
	endif
	return num
endfunction "}}}
function! perforce#getPathFromDiff(out,path) "{{{
	let path = a:path
	if a:out =~ '^===='
		let path = substitute(a:out,'^====.*#.\{-} - \(.*\) ====','\1','')
	endif 
	return path
endfunction "}}}
function! perforce#get_diff_path(outs) "{{{
	" ********************************************************************************
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let path = ''
	for out in outs
		let num = perforce#getLineNumFromDiff(out, num.lnum, num.snum)
		let lnum = num.lnum
		let path = perforce#getPathFromDiff(out,path)
		let candidates += [{
					\ 'word' : lnum.' : '.out,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ }]
	endfor
	return candidates
endfunction "}}}
" �X�y�[�X�Ή�
" ********************************************************************************
" �X�y�[�X�Ή�
" @param[in]	strs		'\ '��������������
" @retval       strs		'\ '���폜����������
" ********************************************************************************
function!  perforce#get_trans_enspace(strs) "{{{
	let strs = a:strs
	return strs
endfunction "}}}

" ********************************************************************************
" �ݒ�ϐ��̏�����
" ********************************************************************************
function! perforce#init() "{{{

	if exists('g:pf_setting')
		return
	else
		" init
		let g:pf_setting = { 
					\ 'bool' : {},
					\ 'str'  : {},
					\ }

		" [] �t�@�C���f�[�^��ǂݍ���

		let g:pf_setting.bool.user_changes_only = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : '���O�Ńt�B���^',
					\ }

		let g:pf_setting.bool.client_changes_only = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : '�N���C�A���g�Ńt�B���^',
					\ }

		let g:pf_setting.bool.is_out_flg = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : '���s���ʂ��o�͂���',
					\ }

		let g:pf_setting.bool.is_out_echo_flg = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : 'echo �Ŏ��s���ʂ��o�͂���',
					\ }

		let g:pf_setting.bool.is_submit_flg = {
					\ 'value' : { 'common' : 1 },
					\ 'description' : '�T�u�~�b�g������',
					\ }

		let g:pf_setting.bool.is_vimdiff_flg = {
					\ 'value' : { 'common' : 0 },
					\ 'description' : 'vimdiff ���g�p����',
					\ }

		let g:pf_setting.bool.ClientMove_recursive_flg = {
					\ 'value' : { 'common' : 0 },
					\ 'description' : 'ClientMove�ōċA���������邩',
					\ }

		let g:pf_setting.str.diff_tool = {
					\ 'value' : { 'common' : 'WinMergeU' },
					\ 'description' : 'Diff �Ŏg�p����c�[��',
					\ }

		let g:pf_setting.str.ClientMove_defoult_root = {
					\ 'value' : { 'common' : 'c:\tmp' },
					\ 'description' : 'ClientMove�̏����t�H���_',
					\ }

		let g:pf_setting.str.ports = {
					\ 'value' : { 'common' : ['localhost:1818'] },
					\ 'description' : 'perforce port',
					\ }

		" �ݒ��ǂݍ���
		call perforce#load($PFDATA)

	endif
endfunction "}}}

" ********************************************************************************
" �ݒ�t�@�C���̓ǂݍ���
" param[in]		file		�ݒ�t�@�C����
" ********************************************************************************
function! perforce#load(file) "{{{

	" �t�@�C����������Ȃ��ꍇ�͏I��
	if filereadable(a:file) == 0
		echo 'Error - not fine '.a:file
		return
	endif

	" �t�@�C����ǂݍ���
	let datas = readfile(a:file)

	" �f�[�^��ݒ肷��
	for data in datas
		let tmp = split(data,"\t")
		exe 'let value = '.tmp[-1]

		let typestr = tmp[0]
		let valname = tmp[1]
		let param   = tmp[2]

		let g:pf_setting[typestr][valname].value[param] = value

		" �^���ς�邽�߁A���������K�v
		unlet value
	endfor

endfunction "}}}

" ********************************************************************************
" �ݒ�t�@�C����ۑ�����
" param[in]		file		�ݒ�t�@�C����
" ********************************************************************************
function! perforce#save(file) "{{{

	let datas = []
	for type in keys(g:pf_setting)
		for val in keys(g:pf_setting[type])
			for param in keys(g:pf_setting[type][val].value)
				let datas += [type."\t".val."\t".param."\t".string(g:pf_setting[type][val].value[param])."\r"]
			endfor
		endfor
	endfor

	" ��������
	call writefile(datas, a:file)

endfunction "}}}

function! perforce#cmds(cmd) "{{{
	" todo
	" [ ] clientName��perforce�Ɉˑ����Ȃ��悤�ɂ���

	if 0 
		if  g:pf_use_defoult_client == 1 " # ��ɍX�V����
			call perforce#get_client_data_from_info() " # �N���C�A���g�f�[�^���X�V����
		endif

		let filter = get(g:pf_filter, 'cmd', 0)" # �t�B���^�̎擾

		" �����ݒ�
		let client = ''
		let changes = ''
		let user = ''
		let port = ''

		if okazu#get_ronri_seki(filet ,g:G_PF_CLIENT)
			let client = '-c
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_PORT)
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_USER)
		endif
		if okazu#get_ronri_seki(filet ,g:G_PF_CHANGE)
		endif
	endif
	return split(system('p4 '.a:cmd),'\n')
endfunction "}}}
