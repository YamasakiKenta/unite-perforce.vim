let $PFTMP = expand("~").'/vim/perforce_tmpfile'
let $PFHAVE = expand("~").'/vim/perforce_have'
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
function! perforce#get_PFUSER() "{{{
	return g:pfuser
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
function! perforce#get_PFCLIENTPATH() "{{{
	return $PFCLIENTPATH
endfunction "}}}
"global
function! perforce#Get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#Get_kk(a:str).'...' : ''
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
		let tmp = a:source.':'.perforce#get_pathSrash(expand("%"))
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
	let outs = perforce#pfcmds('have','',perforce#Get_dd(a:str)) " # �t�@�C�����̎擾
	return perforce#get_paths_from_haves(outs)                   " # �q�b�g�����ꍇ
endfunction "}}}
function! perforce#get_path_from_depot(str) "{{{
	"let out = system('p4 have '.perforce#Get_kk(a:str))
	let outs = perforce#pfcmds('have','',perforce#Get_kk(a:str))
	let path = perforce#get_path_from_have(outs[0])
	return path
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref ���ڃf�[�^�����炤���@�͂Ȃ�����
	let path = substitute(str,'.* \d\d\d\d/\d\d/\d\d root \(.\{-}\) ''.*','\1','g')
	let path = perforce#get_pathSrash(path)
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
	let outs = perforce#pfcmds('print','',' -q '.perforce#Get_kk(path))

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
	let tmp = substitute(tmp,'\nDescription:\zs\_.*\ze\(\nFiles:\)\?','\t'.a:str.'\n','') 

	" �V�K�쐬�̏ꍇ�́A�t�@�C�����܂܂Ȃ�
	if chnum == "" | let tmp = substitute(tmp,'\nFiles:\zs\_.*','','') | endif

	"�ꎞ�t�@�C���̏����o��
	call writefile(split(tmp,'\n'),$PFTMP)

	"�`�F���W���X�g�̍쐬
	return perforce#Get_cmds('more '.perforce#Get_kk($PFTMP).' | p4 change -i') 

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

	let datas = split(system('p4 info'),'\n')
	for data in  datas
		if data =~ 'Client root: '
			let clpath = substitute(data, 'Client root: ','','')
			let clpath = perforce#get_pathSrash(clpath)
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
function! perforce#pfcmds(cmd,head,...) "{{{

	" common ���R�}���h�ɕύX����
	let gcmds  = []
	let gcmd2s = []

	let gcmds += [a:head]

	if a:cmd  =~ 'client' || a:cmd =~ 'changes'	

		if perforce#get_pf_settings('user_changes_only', 'common')[0] == 1
			call add(gcmd2s, '-u '.perforce#get_PFUSER())
		endif 


		if perforce#get_pf_settings('show_max_flg', 'common')[0] == 1
			call add(gcmd2s, '-m '.perforce#get_pf_settings('show_max', 'common')[0])
		endif 

	endif

	if a:cmd  =~ 'changes'
		if perforce#get_pf_settings('client_changes_only', 'common')[0] == 1
			call add(gcmd2s, '-c '.perforce#get_PFCLIENTNAME())
		endif 
	endif

	let cmd = 'p4 '.join(gcmds).' '.a:cmd.' '.join(gcmd2s).' '.join(a:000)

	if perforce#get_pf_settings('show_cmd_flg', 'common')[0] == 1
		echo cmd
		call input("")
	endif

	return split(system(cmd),'\n')
endfunction "}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" ���ʂ̏o�͂��s��
	" @param[in]	str		�\�����镶��
	" @var
	" ********************************************************************************
	"
	if g:pf_settings.is_out_flg.common 
		if g:pf_settings.is_out_echo_flg.common
			echo a:str
		else
			call perforce#LogFile1('p4log', 0, a:str)
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
					\ 'action__text' : substitute(out,'^[<>] ','',''),
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

	if exists('g:pf_settings')
		return
	else
		" init
		let g:pf_settings = {}

		let g:pf_settings.user_changes_only = {
					\ 'common' : 1 ,
					\ 'description' : '���[�U�[���Ńt�B���^',
					\ }

		let g:pf_settings.client_changes_only = {
					\ 'common' : 1 ,
					\ 'description' : '�N���C�A���g�Ńt�B���^',
					\ }

		let g:pf_settings.is_out_flg = {
					\ 'common' : 1 ,
					\ 'description' : '���s���ʂ��o�͂���',
					\ }

		let g:pf_settings.is_out_echo_flg = {
					\ 'common' : 1 ,
					\ 'description' : 'echo �Ŏ��s���ʂ��o�͂���',
					\ }

		let g:pf_settings.is_submit_flg = {
					\ 'common' : 1 ,
					\ 'description' : '�T�u�~�b�g������',
					\ }

		let g:pf_settings.is_vimdiff_flg = {
					\ 'common' : 0 ,
					\ 'description' : 'vimdiff ���g�p����',
					\ }

		let g:pf_settings.ClientMove_recursive_flg = {
					\ 'common' : 0 ,
					\ 'description' : 'ClientMove�ōċA���������邩',
					\ }

		let g:pf_settings.diff_tool = {
					\ 'common' : [ 1, 'WinMergeU', ],
					\ 'description' : 'Diff �Ŏg�p����c�[��',
					\ }

		let g:pf_settings.ClientMove_defoult_root = {
					\ 'common' : [ 1, 'c:\tmp', 'c:\p4tmp', ],
					\ 'description' : 'ClientMove�̏����t�H���_',
					\ }

		let g:pf_settings.ports = {
					\ 'common' : [ 1, 'localhost:1818', ] ,
					\ 'description' : 'perforce port',
					\ }

		let g:pf_settings.is_quit = {
					\ 'common' : 0,
					\ 'description' : '���s��A����',
					\ }

		let g:pf_settings.show_max = {
					\ 'common' : [ 100, ] , 
					\ 'description' : '�\������t�@�C����',
					\ }

		let g:pf_settings.show_max_flg = {
					\ 'common' : 0,
					\ 'description' : '�t�@�C�����̐���������',
					\ }

		let g:pf_settings.show_cmd_flg = {
					\ 'common' : 1,
					\ 'description' : '�R�}���h��\������',
					\ }

		" �ݒ��ǂݍ���
		call perforce#load($PFDATA)

		" �N���C�A���g�f�[�^�̓ǂݍ���
		call perforce#get_client_data_from_info()

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
		exe 'let g:pf_settings["'.join(tmp[0:-2],'"]["').'"] = '.tmp[-1]

		" �^���ς�邽�߁A���������K�v
	endfor

endfunction "}}}

" ********************************************************************************
" �ݒ�t�@�C����ۑ�����
" param[in]		file		�ݒ�t�@�C����
" ********************************************************************************
function! perforce#save(file) "{{{

	let datas = []

	let tmp  = ''
	for type in keys(g:pf_settings)
		for val in keys(g:pf_settings[type])
			if val != 'description'
				let datas += [type."\t".val."\t".string(g:pf_settings[type][val])."\r"]
			endif
		endfor
	endfor

	" ��������
	call writefile(datas, a:file)

endfunction "}}}

" ********************************************************************************
" �ݒ�f�[�^���擾����
" @param[in]	type		pf_settings �̐ݒ�̎��
" @param[in]	kind		common �Ȃ�, source �̎��
" @retval		rtns 		�擾�f�[�^
" ********************************************************************************
function! perforce#get_pf_settings(type, kind) "{{{
	" �ݒ肪�Ȃ��ꍇ�́A���ʂ��Ăяo��
	let val     = get(g:pf_settings[a:type],a:kind,g:pf_settings[a:type].common)
	let valtype = type(val)

	if valtype == 3
		" ���X�g�̏ꍇ�́A�����Ŏ擾����
		let rtns = <SID>get_pf_settings_from_lists(val)
	else
		let rtns = val
	endif

	return rtns
endfunction "}}}

" ********************************************************************************
" BIT ���Z�ɂ���āA�f�[�^���擾����
" @param[in]	datas	{ bit, ������, ... } 
" @retval   	rtns 	���X�g��Ԃ�
" ********************************************************************************
function! s:get_pf_settings_from_lists(datas) "{{{

	" �L���ȃ��X�g�̎擾 ( ��ڂ́A�t���O�������Ă��邽�߃X�L�b�v���� )
	let nums = bit#get_nums_form_bit(a:datas[0]*2)

	" �L���Ȉ����̂ݕԂ�
	return map(copy(nums), 'a:datas[v:val]')

endfunction "}}}

"okazu# ����̈ڐA
function! perforce#GetFileNameForUnite(args, context) "{{{
	" �t�@�C�����̎擾
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
function! perforce#Get_kk(str) "{{{
	"return substitute(a:str,'^\"?\(.*\)\"?','"\1"','')
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction "}}}
function! perforce#LogFile1(name, deleteFlg, ...) "{{{
	" ********************************************************************************
	" �V�����t�@�C�����J���ď������݋֎~�ɂ��� 
	" @param[in]	name		�������ݗptmpFileName
	" @param[in]	deleteFlg	����������
	" @param[in]	[...]		�������ރf�[�^
	" ********************************************************************************
	
	let @t = expand("%:p") " # map�ŌĂяo���p
	let name = a:name

	" �J���Ă��邩���ׂ�
	let bnum = bufwinnr(name) 

	if bnum == -1
		" ��ʓ��ɂȂ���ΐV�K�쐬
		exe 'sp ~/'.name
		%delete _          " # �t�@�C������
		setl buftype=nofile " # �ۑ��֎~
		setl fdm=manual
		call perforce#MyQuit()
	else
		" �\�����Ă���Ȃ�؂�ւ���
		exe bnum . 'wincmd w'
	endif

	" ����������
	if a:deleteFlg == 1
		%delete _
	endif

	" �������݃f�[�^������Ȃ珑������
	if exists("a:1") 
		call append(0,a:1)
	endif
	cal cursor(1,1) " # ��s�ڂɈړ�����

endfunction "}}}
function! perforce#Map_diff() "{{{
	map <buffer> <up> [c
	map <buffer> <down> ]c
	map <buffer> <left> dp:<C-u>diffupdate<CR>
	map <buffer> <right> dn:<C-u>diffupdate<CR>
	map <buffer> <tab> <C-w><C-w>
endfunction "}}}
function! perforce#event_save_file(tmpfile,strs,func) "{{{
	" ********************************************************************************
	" �t�@�C����ۑ������Ƃ��ɁA�֐������s���܂�
	" @param[in]	tmpfile		�ۑ�����t�@�C���� ( ��������t�@�C���� ) 
	" @param[in]	strs		�����̕���
	" @param[in]	func		���s����֐���
	" ********************************************************************************


	"��ʐݒ�
	exe 'vnew' a:tmpfile
    setlocal noswapfile bufhidden=hide buftype=acwrite

	"���̏�������
	%delete _
	call append(0,a:strs)

	"��s�ڂɈړ�
	cal cursor(1,1) 

	aug perforce_event_save_file "{{{
		au!
		exe 'autocmd BufWriteCmd <buffer> nested call '.a:func
	aug END "}}}

endfunction "}}}
function! perforce#get_pathEn(path) "{{{
	return substitute(a:path,'/','\','g') " # / �}�[�N�ɓ���
endfunction "}}}
function! perforce#get_pathSrash(path) "{{{
	return substitute(a:path,'\','/','g') " # / �}�[�N�ɓ���
endfunction "}}}
function! perforce#is_different(path,path2) "{{{
	" ********************************************************************************
	" �����𒲂ׂ�
	" @param[in]	path				��r�t�@�C��1
	" @param[in]	path2				��r�t�@�C��2
	" @retval		flg			TRUE	��������
	" 							FALSE	�����Ȃ�
	" ********************************************************************************
	let flg = 1
	let outs = perforce#Get_cmds('fc '.perforce#Get_kk(a:path).' '.perforce#Get_kk(a:path2))
	if outs[1] =~ '^FC: ����_�͌��o����܂���ł���'
		let flg = 0
	endif
	return flg
endfunction "}}}
function! perforce#MyQuit() "{{{
	map <buffer> q :q<CR>
endfunction "}}}
function! perforce#Get_cmds(cmd) "{{{
	return split(system(a:cmd),'\n')
endfunction "}}}
