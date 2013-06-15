let s:save_cpo = &cpo
set cpo&vim

function! s:_len_compara(i1, i2) "{{{
	let l1 = len(a:i1)
	let l2 = len(a:i2)
	"return l1 == l2 ? 0 : l1 > l2 ? 1 : -1
	return l1 == l2 ? 0 : l1 < l2 ? 1 : -1
endfunction
"}}}

function! s:get_list(tmp) "{{{
	return (type(a:tmp) == type([])) ? a:tmp : [a:tmp]
endfunction
"}}}
function! s:set_dict_extend(dict1, dict2) "{{{
	" �����L�[������ꍇ�́A���X�g�Ō������ĕԂ�
	
	" �傫������dict1 �ɐݒ肷��
	let [dict1, dict2] = [a:dict1, a:dict2]

	" a:dict1 ��D�悳����
	let dict_new = dict1
	for key in keys(dict2)
		let dict_new[key] = exists('dict_new[key]')
					\ ? extend(s:get_list(a:dict1[key]), s:get_list(a:dict2[key])) 
					\ : dict2[key]
	endfor

	return dict_new
endfunction
"}}}
function! s:get_fname_key(file_d, fname_full) "{{{
	" �����^�ɓo�^���Ă���L�[���A�������� 
	" ( �L�[��������܂ŁA�t�@�C������Z������ ) 

	let file_d    = a:file_d
	let fname_tmp  = substitute(a:fname_full, '\\', '\/', 'g')

	while len(fname_tmp) && !exists('file_d[fname_tmp]')
		let fname_tmp  = matchstr(fname_tmp, '.\{-}[\/\\]\zs.*')
	endwhile
	return fname_tmp
endfunction
"}}}
function! s:get_len_sort(lists) "{{{
	return sort(a:lists, "s:_len_compara")
endfunction
"}}}
function! s:save(name, dict) "{{{

	let tmps  = ['let g:tmp = '] + map(split(string(a:dict), '},\zs'), "'	\\ '.v:val")

	let lines = []
	call extend(lines, [
				\ 'let s:save_cpo = &cpo',
				\ 'set cpo&vim',
				\ '',
				\ 'if exists("g:tmp")',
				\ '	unlet g:tmp',
				\ 'endif',
				\ '',
				\ ])

	call extend(lines, tmps)
	call extend(lines, [
				\ '',
				\ 'let &cpo = s:save_cpo',
				\ 'unlet s:save_cpo',
				\ ])
	call writefile(lines, expand(a:name))
endfunction
"}}}
function! s:load(name, default) "{{{
	" �t�@�C����ǂݍ���
	if exists('g:tmp')
		unlet g:tmp
	endif

	if filereadable(expand(a:name))
		exe 'so '.a:name
	endif

	return get(g:, 'tmp', a:default)
endfunction
"}}}

function! s:MyQuit() "{{{
	map <buffer> q :q<CR>
endfunction
"}}}
function! s:LogFile(name, deleteFlg, ...) "{{{
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
		call s:MyQuit()
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

	return bufnr("%")
endfunction
"}}}
function! s:Get_cmds(cmd) "{{{
	return split(system(a:cmd),'\n')
endfunction
"}}}
function! s:is_different(path,path2) "{{{
	" ********************************************************************************
	" �����𒲂ׂ�
	" @param[in]	path				��r�t�@�C��1
	" @param[in]	path2				��r�t�@�C��2
	" @retval		flg			TRUE	��������
	" 							FALSE	�����Ȃ�
	" ********************************************************************************
	let flg = 1
	let outs = s:Get_cmds('fc '.s:get_kk(a:path).' '.s:Get_kk(a:path2))
	if outs[1] =~ '^FC: ����_�͌��o����܂���ł���'
		let flg = 0
	endif
	return flg
endfunction
"}}}
function! s:get_pathEn(path) "{{{
	return substitute(a:path,'/','\','g') " # / �}�[�N�ɓ���
endfunction
"}}}
function! s:GetFileNameForUnite(args, context) "{{{
	" �t�@�C�����̎擾
	let a:context.source__path = expand('%:p')
	let a:context.source__linenr = line('.')
	call unite#print_message('[line] Target: ' . a:context.source__path)
endfunction
"}}}
function! s:selectEdit_write(args) "{{{
"********************************************************************************
" Select Edit �̕ۑ�
" @param[in]	args.start	�J�n�ʒu
" @param[in]	args.end	�I���ʒu
" @param[in]	args.bufnr	�ԍ�
"********************************************************************************

	let start    = a:args.start
	let end      = a:args.end
	let bufnr    = a:args.bufnr

	" tmpfile�̕ۑ�
	set nomodified
	let nowbufnr = bufnr('%')
	let strs     = getline(0,'$')

	" �s�̕ύX
	let a:args.end = start + line('$') - 1

	" args�̍X�V
	call s:event_save_file_autocmd('s:selectEdit_write',a:args)


	" �ҏW����t�@�C�� �̕ҏW
	exe bufnr 'buffer'

	" �폜
	exe start.','.end 'delete'

	" �ǉ�
	call append(start-1,strs)

	" tmpfile�ɖ߂�
	exe nowbufnr 'buffer'

endfunction
"}}}
function! s:event_save_file(tmpfile,strs,func,args) "{{{
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

	call s:event_save_file_autocmd(a:func,a:args)

endfunction
"}}}
function! s:event_save_file_autocmd(func,args) "{{{

	aug okazu_event_save_file
		au!
		exe 'autocmd BufWriteCmd <buffer> nested call '.a:func.'('.string(a:args).')'
	aug END

endfunction
"}}}
function! s:change_extension(exts) "{{{
" ********************************************************************************
" �t�@�C���̐؂�ւ� ( C ���� ) 
" ********************************************************************************
	let extension = expand("%:e")

	if exists('a:exts[extension]')
		exe 'e %:r.'.a:exts[extension]
	endif

endfunction
"}}}
function! s:change_unite() "{{{
" ********************************************************************************
" �t�@�C���̐؂�ւ� ( unite ) 
" ********************************************************************************
	let root = substitute(expand("%:h"), '[\\/][^\\/]*$', '', '')
	let file = expand("%:t")
	let type = substitute(expand("%:h"), '.*[\\/]\ze.\{-}[\\/]', '', '')

	echo type
	if type =~ 'unite[\\/]kinds'
		let file = substitute(file, 'k_', '', '')
		exe 'e '.root.'/sources/'.file
	elseif type =~ 'unite[\\/]sources'
		exe 'e '.root.'/kinds/k_'.file
	endif

endfunction
"}}}
function! s:map_diff_reset() "{{{
	map <buffer> <A-up> <A-up>
	map <buffer> <A-down> <A-down>
	map <buffer> <A-left> <A-left>
	map <buffer> <A-right> <A-right>
endfunction
"}}}
function! s:map_diff_tab() "{{{
	"********************************************************************************
	" �^�u�؂�ւ����ɏ�����ǉ����邽�ߍ쐬����
	"********************************************************************************
	wincmd w
endfunction
"}}}
function! s:map_diff() "{{{
	map <buffer> <A-up> [c
	map <buffer> <A-down> ]c
	map <buffer> <A-left>  :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <A-right> :diffget<CR>:<C-u>diffupdate<CR>|"
	map <buffer> <tab> :<C-u>call s:map_diff_tab()<CR>|"
endfunction
"}}}

"=== new ===
function! s:_get_dict_from_list(datas) "{{{
	" ���X�g�f�[�^���L�[�Ƃ��鎫���^���쐬����
	let datas  = a:datas
	let dict_d = {}

	for data in datas
		let dict_d[data] = 1
	endfor
	return dict_d
endfunction
"}}}
function! s:add_uniq(datas, val) "{{{
	" �����^�̒l�ɓ����l���Ȃ��ꍇ�́A�擪�ɒǉ�����
	let dict_d = s:_get_dict_from_list

	for val in s:get_list(a:val)
		if !exists('dict_d[val]')
			call add(datas, val)
		endif
	endfor

	return datas
endfunction
"}}}
let &cpo = s:save_cpo
unlet s:save_cpo
