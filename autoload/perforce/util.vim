let s:save_cpo = &cpo
set cpo&vim

function! perforce#util#get_files(...)
	return get(a:, 1, "") == "" ? [expand("%:p")] : a:000
endfunction

function! perforce#util#get_client_root(...) 
	return call(s:get_client_root, a:000)
endfunction 

function! perforce#util#get_client_root_from_client(...)
	return call(s:get_client_root_from_client, a:000)
endfunction

function! perforce#util#open_lines(...)
	return call(s:open_lines, a:000)
endfunction

function! perforce#util#log_file(...)
	return call(s:Common.LogFile, a:000)
endfunction

function! s:get_client_root(...) 
	if get(a:, '1', 0) != 0 || !exists('g:get_client_root_cache')
		" ���s���ׂ̈ɁA����������
		let g:get_client_root_cache = ""
		let lines = split(system('p4 info'), "\n")
		let word = '^Client root: '
		for line in lines 
			if line =~ word
				let g:get_client_root_cache = matchstr(line, word.'\zs.*')
				break
			endif
		endfor
	endif
	return g:get_client_root_cache
endfunction

function! s:get_client_root_from_client(client) 
	let outs = filter(split(system('p4 '.a:client.' client -o'),"\n"), "v:val =~ '^Root:'")
	let rtn_d = {
				\ 'root'   : matchstr(outs[0], '^Root:\t\zs.*'),
				\ 'client' : matchstr(substitute(a:client, '\s\+', ' ', 'g'), '^\s*\zs\S.\{-}\ze\s*$')
				\ }
	return rtn_d
endfunction

function! s:open_lines(datas) 
	let datas = a:datas
	tabe

	" �ŏ��̉�ʂ̍X�V
	call append(0, datas[0])
	call cursor(1,1)

	" 2��ʖڂ���́A��������
	for lines in datas[1:]
		new
		call append(0, lines)
		call cursor(1,1)
	endfor	
endfunction

function! s:LogFile(name, deleteFlg, ...) 
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
		map <buffer> q :q<CR>
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

let &cpo = s:save_cpo
unlet s:save_cpo
