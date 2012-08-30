" ================================================================================
"okazu# ����̈ڐA
" ================================================================================
function! common#GetFileNameForUnite(args, context) "{{{
	" �t�@�C�����̎擾
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	let a:context.source__depots = perforce#get_depots(a:args, a:context.source__path)
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction "}}}
function! common#Get_kk(str) "{{{
	"return substitute(a:str,'^\"?\(.*\)\"?','"\1"','')
	return len(a:str) ? '"'.a:str.'"' : ''
endfunction "}}}
function! common#LogFile1(name, deleteFlg, ...) "{{{
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
function! common#map_diff() "{{{
	map <buffer> <up> [c
	map <buffer> <down> ]c
	map <buffer> <left> do
	map <buffer> <right> do
	map <buffer> <tab> <C-w><C-w>
endfunction "}}}
function! common#event_save_file(tmpfile,strs,func) "{{{
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
function! common#get_pathEn(path) "{{{
	return substitute(a:path,'/','\','g') " # / �}�[�N�ɓ���
endfunction "}}}
function! common#get_pathSrash(path) "{{{
	return substitute(a:path,'\','/','g') " # / �}�[�N�ɓ���
endfunction "}}}
function! common#is_different(path,path2) "{{{
	" ********************************************************************************
	" �����𒲂ׂ�
	" @param[in]	path				��r�t�@�C��1
	" @param[in]	path2				��r�t�@�C��2
	" @retval		flg			TRUE	��������
	" 							FALSE	�����Ȃ�
	" ********************************************************************************
	let flg = 1
	let outs = common#Get_cmds('fc '.common#Get_kk(a:path).' '.common#Get_kk(a:path2))
	if outs[1] =~ '^FC: ����_�͌��o����܂���ł���'
		let flg = 0
	endif
	return flg
endfunction "}}}
function! common#MyQuit() "{{{
	map <buffer> q :q<CR>
endfunction "}}}
function! common#Get_cmds(cmd) "{{{
	let rtns = split(system(a:cmd),'\n')
	return rtns
endfunction "}}}
