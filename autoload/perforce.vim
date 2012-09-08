let $PFTMP = expand( exists('$PFTMP') ? $PFTMP : '~' )
let $PFTMPFILE  = $PFTMP.'\perforce\tmpfile'
let $PFHAVE = $PFTMP.'\perforce\have'
let $PFDATA = $PFTMP.'\perforce\data'
" ================================================================================
"@ �擾
" ================================================================================
function! perforce#get_filename_for_unite(args, context) "{{{
	" �t�@�C�����̎擾
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	let a:context.source__depots = perforce#get_depots(a:args, a:context.source__path)
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
"@set
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
"@get
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
function! perforce#get_PFCLIENTPATH() "{{{
	return $PFCLIENTPATH
endfunction "}}}
function! perforce#get_PFPORT() "{{{
	return $PFPORT
endfunction "}}}
function! perforce#get_PFUSER() "{{{
	return g:pfuser
endfunction "}}}
"@global
function! perforce#Get_dd(str) "{{{
	return len(a:str) ? '//...'.perforce#common#Get_kk(a:str).'...' : ''
endfunction "}}}
function! perforce#pf_diff_tool(file,file2) "{{{
	call g:PerforceDiff(a:file,a:file2)
endfunction "}}}
"@static
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
		let tmp = a:source.':'.common#get_pathSrash(expand("%"))
		let tmp = substitute(tmp, ' ','\\ ', 'g')
		let tmp = 'Unite '.tmp
		echo tmp
		exe tmp
	endif

endfunction "}}}

function! perforce#get_ClientName_from_client(str) "{{{
	return substitute(copy(a:str),'Client \(\S\+\).*','\1','g')
endfunction "}}}
function! perforce#get_ClientPathFromName(str) "{{{
	let str = system('p4 clients | grep '.a:str) " # ref ���ڃf�[�^�����炤���@�͂Ȃ�����
	let path = substitute(str,'.* \d\d\d\d/\d\d/\d\d root \(.\{-}\) ''.*','\1','g')
	let path = common#get_pathSrash(path)
	return path
endfunction "}}}
function! perforce#pfFind(...) "{{{
	if a:0 == 0
		let str  = input('Find : ')
	else
		let str = a:1
	endif 
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
	let outs = perforce#pfcmds('print','',' -q '.perforce#common#Get_kk(path))

	" �G���[������������t�@�C�����������āA���ׂĂƔ�r ( �ċA )
	if outs[0] =~ "is not under client's root "
		call perforce#pfDiff_from_fname(path)
		return
	endif

	"tmp�t�@�C���̏����o��
	call writefile(outs,$PFTMPFILE)
	"}}}

	" ���s����v���Ȃ��̂ŕۑ������� "{{{
	exe 'sp' $PFTMPFILE
	set ff=dos
	wq
	"}}}

	" depot�Ȃ�path�ɕϊ�
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" ���ۂɔ�r 
	call perforce#pf_diff_tool($PFTMPFILE,path)

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
	call writefile(split(tmp,'\n'),$PFTMPFILE)

	"�`�F���W���X�g�̍쐬
	return perforce#common#Get_cmds('more '.perforce#common#Get_kk($PFTMPFILE).' | p4 change -i') 

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
			let clpath = common#get_pathSrash(clpath)
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
	" �f�[�^�̎擾 {{{
	let outs = perforce#pfcmds('describe -ds','',a:chnum)

	" new file �p�ɂ����ŏ�����
	let datas = []

	" ��ƒ��̃t�@�C��
	if outs[0] =~ '\*pending\*' || a:chnum == 'default'
		let files = perforce#pfcmds('opened','','-c '.a:chnum)
		call map(files, "perforce#get_depot_from_opened(v:val)")

		let outs = []
		for file in files 
			let list_tmps = perforce#pfcmds('diff -ds','',file)

			for list_tmp in list_tmps
				if list_tmp =~ '- file(s) not opened for edit.'
					let file_tmp = substitute(file, '.*[\/]','','')
					let path = perforce#get_path_from_depot(file)
					let datas += [{'files' : file_tmp, 'adds' : len(readfile(path)), 'changeds' : 0, 'deleteds' : 0, }]
				else
					let outs += [list_tmp]
				endif
			endfor
		endfor


	endif

	let find = ' \(\d\+\) chunks \(\|\(\d\+\) / \)\(\d\+\) lines'
	for out in outs
		if out =~ "===="
			let datas += [{'files' : substitute(out,'.*/\(.\{-}\)#.*','\1',''), 'adds' : 0, 'changeds' : 0, 'deleteds' : 0, }]
		elseif out =~ 'add'.find
			let datas[-1].adds = substitute(out,'add'.find,'\4','')
		elseif out =~ 'deleted'.find
			let datas[-1].deleteds = substitute(out,'deleted'.find,'\4','')
		elseif out =~ 'changed'.find
			let a = substitute(out,'changed'.find,'\3','')
			let b = substitute(out,'changed'.find,'\4','')
			let datas[-1].changeds = a > b ? a : b
		endif
	endfor
	"}}}
	"
	"�f�[�^�̏o�� {{{
	let outs = []
	for data in datas 
		let outs += [data["files"]."\t\t".data["adds"]."\t".data["deleteds"]."\t".data["changeds"]]
	endfor
	call perforce#LogFile(outs)
	"}}}
endfunction "}}}
function! perforce#is_submitted_chnum(chnum) "{{{

endfunction "}}}
function! perforce#pfcmds(cmd,head,...) "{{{

	" common ���R�}���h�ɕύX����
	let gcmds  = []
	let gcmd2s = []

	let gcmds += [a:head]

	if a:cmd  == 'clients' || a:cmd == 'changes'	

		if perforce#setting#get('user_changes_only', 'common').datas[0] == 1
			call add(gcmd2s, '-u '.perforce#get_PFUSER())
		endif 


		if perforce#setting#get('show_max_flg', 'common').datas[0] == 1
			call add(gcmd2s, '-m '.perforce#setting#get('show_max', 'common').datas[0])
		endif 

	endif

	if a:cmd  =~ 'changes'
		if perforce#setting#get('client_changes_only', 'common').datas[0] == 1
			call add(gcmd2s, '-c '.perforce#get_PFCLIENTNAME())
		endif 
	endif

	let cmd = 'p4 '.join(gcmds).' '.a:cmd.' '.join(gcmd2s).' '.join(a:000)

	if perforce#setting#get('show_cmd_flg', 'common').datas[0]
		echo cmd
		if perforce#setting#get('show_cmd_stop_flg', 'common').datas[0]
			call input("")
		endif
	endif

	let rtn = split(system(cmd),'\n')

	" ��\���ɂ���R�}���h
	if perforce#setting#get('filters_flg', 'common').datas
		let filters = perforce#setting#get('filters', 'common').datas
		let filter = join(filters, '\|')
		call filter(rtn, 'v:val !~ filter')
	endif

	return rtn
endfunction "}}}
function! perforce#LogFile(str) "{{{
	" ********************************************************************************
	" ���ʂ̏o�͂��s��
	" @param[in]	str		�\�����镶��
	" @var
	" ********************************************************************************
	"
	if perforce#setting#get('is_out_flg', 'common').datas[0]
		if perforce#setting#get('is_out_echo_flg', 'common').datas[0]
			echo a:str
		else
			call perforce#common#LogFile('p4log', 0, a:str)
		endif
	endif

endfunction "}}}
"@diff
function! perforce#get_lnum_from_diff(str,lnum,snum) "{{{
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
		let tmp = split(substitute(str,find,',',''),',')
		let tmpnum = tmp[1] - 1
		let num.lnum = tmpnum
		let num.snum = tmpnum
	elseif str =~ '^\d\+,\d\+'.find.'\d\+'
		let tmp = split(substitute(str,find,',',''),',')
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
" 
function! perforce#is_p4_have(str) "{{{
	" ********************************************************************************
	" �N���C�A���g�Ƀt�@�C�������邩���ׂ�
	" @param[in]	str				�t�@�C���� , have �̕Ԃ�l
	" @retval       flg		TRUE 	���݂���
	" @retval       flg		FLASE 	���݂��Ȃ�
	" ********************************************************************************
	let str = system('p4 have '.perforce#common#Get_kk(a:str))
	let flg = perforce#is_p4_have_from_have(str)
	return flg
endfunction "}}}
function! perforce#is_p4_have_from_have(str) "{{{

	if a:str =~ '- file(s) not on client.'
		let flg = 0
	else
		let flg = 1
	endif

	return flg

endfunction "}}}
function! perforce#get_trans_enspace(strs) "{{{
	" �X�y�[�X�Ή�
	" ********************************************************************************
	" �X�y�[�X�Ή�
	" @param[in]	strs		'\ '��������������
	" @retval       strs		'\ '���폜����������
	" ********************************************************************************
	let strs = a:strs
	return strs
endfunction "}}}
function! perforce#init() "{{{
	call perforce#setting#init()
endfunction "}}}
"================================================================================
" ���ёւ�
"================================================================================
"@get_file
function! perforce#get_file_from_where(str) "{{{
	let file = a:str
	let file = substitute(file,'.*[\/]','','')
	let file = substitute(file,'\n','','g')
	return file
endfunction "}}}
"@get_depot(s)
function! perforce#get_depot_from_have(str) "{{{
	return matchstr(a:str,'.\{-}\ze#\d\+ - .*')
endfunction "}}}
function! perforce#get_depot_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # ���r�W�����ԍ��̍폜
endfunction "}}}
"@get_path(s)
function! perforce#get_path_from_where(str) "{{{
	return matchstr(a:str, '.\{-}\zs\w*:.*\ze\n.*')
endfunction "}}}
function! perforce#get_path_from_have(str) "{{{
	let rtn = matchstr(a:str,'.\{-}#\d\+ - \zs.*')
	let rtn = substitute(rtn, '\\', '/', 'g')
	return rtn
endfunction "}}}
function! perforce#get_path_from_depot(str) "{{{
	let out = system('p4 where '.a:str)
	let path = perforce#get_path_from_where(out)
	return path
endfunction "}}}
function! perforce#get_paths_from_haves(strs) "{{{
	return map(a:strs,"perforce#get_path_from_have(v:val)")
endfunction "}}}
function! perforce#get_paths_from_fname(str) "{{{
	" �t�@�C��������
	let outs = perforce#pfcmds('have','',perforce#Get_dd(a:str)) " # �t�@�C�����̎擾
	return perforce#get_paths_from_haves(outs)                   " # �q�b�g�����ꍇ
endfunction "}}}
"@p4_change
function! perforce#get_depots(args, path) "{{{
	" ********************************************************************************
	" depots ���擾����
	" @param[in]	args	�t�@�C����
	" @param[in]	context
	" ********************************************************************************
	if len(a:args) > 0
		let depots = a:args
	else
		let depots = [a:path]
	endif
	return depots
endfunction "}}}
function! perforce#get_pfchanges(context,outs,kind) "{{{
	" ********************************************************************************
	" p4_changes Untie �p�� �Ԃ�l��Ԃ�
	" @param(in)	context	
	" @param(in)	outs
	" @param(in)	kind	
	" ********************************************************************************
	let outs = a:outs
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : a:kind,
				\ 'action__chname' : '',
				\ 'action__chnum' : perforce#get_ChangeNum_from_changes(v:val),
				\ 'action__depots' : a:context.source__depots,
				\ }")


	return candidates
endfunction "}}}
"@source
function! perforce#get_source_file_from_path(path) "{{{
	" ********************************************************************************
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
	" ********************************************************************************
	let path = a:path
	let lines = readfile(path)
	let candidates = []
	let lnum = 1
	for line in lines
		let candidates += [{
					\ 'word' : lnum.' : '.line,
					\ 'kind' : 'jump_list',
					\ 'action__line' : lnum,
					\ 'action__path' : path,
					\ 'action__text' : line,
					\ }]
		let lnum += 1
	endfor
	return candidates
endfunction "}}}
function! perforce#get_source_diff_from_diff(outs) "{{{
	" ********************************************************************************
	" �����̏o�͂��AUnite��jump_list��������
	" @param[in]	outs		�����̃f�[�^
	" ********************************************************************************
	let outs = a:outs
	let candidates = []
	let num = { 'lnum' : 1 , 'snum' : 1 }
	let path = ''
	for out in outs
		let num = perforce#get_lnum_from_diff(out, num.lnum, num.snum)
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
