
let $PFTMP = expand("~")."/vim/tmpfile"
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
	return g:pf_user_changes_only && g:pfuser !=# "" ? ' -u '.g:pfuser.' ' : ''
endfunction "}}}
function! perforce#get_PFCLIENTNAME() "{{{
	return $PFCLIENTNAME
endfunction "}}}
"[ ] �g�p���Ă���ꏊ�̕ύXo
"�R�}���h�Ő��䂷��
function! perforce#get_PFCLIENTNAME_for_pfcmd(...) "{{{
	return g:pf_client_changes_only && $PFCLIENTNAME !=# "" ? ' -c '.$PFCLIENTNAME.' ' : ''
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

	"exe 'Unite '.a:source.':'.perforce#Get_dd(expand("%:t"))
	exe 'Unite '.a:source.':'.okazu#get_pathSrash(expand("%"))

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
function! perforce#pfLogFile(str) "{{{
	" ********************************************************************************
	" ���ʂ̏o�͂��s��
	" @param[in]	str		�\�����镶��
	" ********************************************************************************
	"
	if g:pf_is_out_flg
		call okazu#LogFile('p4log',a:str)
	endif

endfunction "}}}
function! perforce#get_ClientName_from_client(str) "{{{
	return substitute(copy(a:str),'Client \(\S\+\).*','\1','g')
endfunction "}}}
function! perforce#get_path_from_have(str) "{{{
	return substitute(a:str,'\(.\{-}\)#\d\+ - \(\S*\)','\2','') 
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
	let tmpfile = $PFTMP

	" �ŐV REV �̃t�@�C���̎擾 "{{{
	let outs = perforce#cmds('print -q '.okazu#Get_kk(path))

	" �G���[������������t�@�C�����������āA���ׂĂƔ�r ( �ċA )
	if outs[0] =~ "is not under client's root "
		call perforce#pfDiff_from_fname(path)
		return
	endif

	"tmp�t�@�C���̏����o��
	call writefile(outs,tmpfile)
	"}}}

	" ���s����v���Ȃ��̂ŕۑ������� "{{{
	exe 'sp' tmpfile
	set ff=dos
	wq
	"}}}

	" depot�Ȃ�path�ɕϊ�
	if path =~ "^//depot.*"
		let path = perforce#get_path_from_depot(path)
	endif

	" ���ۂɔ�r 
	call perforce#pf_diff_tool(tmpfile,path)

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

	call perforce#pfLogFile(paths)
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

	"�ꎞ�ۑ�����t�@�C���p�X��
	let tmpfile = $PFTMP

	"ChangeList�̐ݒ�f�[�^���ꎞ�ۑ�����
	let tmp     = system('p4 change -o '.chnum)                          

	"�R�����g�̕ҏW
	let tmp     = substitute(tmp,'\nDescription:\zs.*>','\t'.a:str,'') 

	"�ꎞ�t�@�C���̏����o��
	call writefile(split(tmp,'\n'),tmpfile)                            

	"�`�F���W���X�g�̍쐬
	return okazu#Get_cmds('more '.okazu#Get_kk(tmpfile).' | p4 change -i') 

endfunction "}}}
function! perforce#pfNewChange() "{{{
	let str = input('ChangeList Comment (new) : ')

	if str != ""
		" �`�F���W���X�g�̍쐬 ( new )
		let outs = perforce#pfChange(str) 
		call perforce#pfLogFile(outs)
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
	call perforce#pfLogFile(outs)
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
