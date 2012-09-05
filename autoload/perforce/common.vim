function! perforce#common#Get_cmds(cmd) "{{{
	return split(system(a:cmd),'\n')
endfunction "}}}
function! perforce#common#Get_kk(str) "{{{
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction "}}}
function! perforce#common#LogFile(name, deleteFlg, ...) "{{{
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
		call common#MyQuit()
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
function! perforce#common#LogFile(name, deleteFlg, ...) "{{{
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
		call common#MyQuit()
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
function! perforce#common#do_move()"{{{
endfunction"}}}
function! perforce#common#event_save_file()"{{{
endfunction"}}}
function! perforce#common#get_pathSrash(str)"{{{
	return substitute(a:str, '\\', '\/', 'g')
endfunction"}}}
function! perforce#common#map_diff() "{{{
	map <buffer> <A-up> [c
	map <buffer> <A-down> ]c
	map <buffer> <A-left>  :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <A-right> :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <tab> <C-w><C-w>|"

	echo 'vimwork'
endfunction "}}}
function! perforce#common#event_save_file(tmpfile,strs,func,args) "{{{
" ********************************************************************************
" �t�@�C����ۑ������Ƃ��ɁA�֐������s���܂�
" @param[in]	tmpfile		�ۑ�����t�@�C���� ( ��������t�@�C���� ) 
" @param[in]	strs		�����̕���
" @param[in]	func		���s����֐���
" @param[in]	args		���s����֐����ɓn�� ����
" ********************************************************************************

	"��ʐݒ�
	let bnum = bufwinnr(a:tmpfile) 

	if bnum == -1
		exe 'vnew' a:tmpfile
		setlocal noswapfile bufhidden=hide buftype=acwrite
	else
		" �\�����Ă���Ȃ�؂�ւ���
		exe bnum . 'wincmd w'
	endif

	"���̏�������
	%delete _
	call append(0,a:strs)

	"��s�ڂɈړ�
	call cursor(1,1) 

	call common#event_save_file_autocmd(a:func,a:args)

endfunction "}}}
function! perforce#common#event_save_file_autocmd(func,args) "{{{

	aug okazu_event_save_file
		au!
		exe 'autocmd BufWriteCmd <buffer> nested call '.a:func.'('.string(a:args).')'
	aug END

endfunction "}}}
