let s:save_cpo = &cpo
set cpo&vim

let s:L = vital#of('unite-perforce.vim')
let s:File = s:L.import('Mind.Y_files')

function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" �⊮ : perforce ��ɑ��݂���t�@�C����\������
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction "}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" @param[in] add_flg true : �N���C�A���g�ɑ��݂��Ȃ��ꍇ�́A�t�@�C����ǉ�
	" @param[in] a:000     {�t�@�C����}     �l���Ȃ��ꍇ�́A���݂̃t�@�C����ҏW����
	" @retval    �Ȃ�
	" ********************************************************************************
	"
	" �ҏW����t�@�C�ږ��̎擾

	if a:0 == 0
		let _files = [perforce#common#get_now_filename()]
	else
		" �t�@�C�������w�肳��Ă���ꍇ
		let _files = a:000
	endif


	" init
	let file_d = {
				\ 'add' : '',
				\ 'edit' : '',
				\ 'null' : '',
				\ }

	" �t�@�C�������݂��Ȃ��ꍇ�A�ǉ�����
	for _file in _files
		let cmd = 'null'
		if perforce#is_p4_have(_file)
			let cmd = 'edit'
		else
			if ( a:add_flg == 1 )
				let cmd = 'add'
			endif
		endif

		let file_d[cmd] = file_d[cmd].' '.perforce#common#get_kk(_file)
	endfor

	unlet file_d['null']

	" init 
	let outs = []

	" �R�}���h�����s����
	for cmd in keys(file_d)
		let _file = file_d[cmd]
		if _file != ''
			call extend(outs, perforce#pfcmds_new_outs(cmd, '', _file))
		endif
	endfor

	call perforce#LogFile(outs)
endfunction
"}}}
function! perforce_2#pfDiff(...) "{{{
	" ********************************************************************************
	" @param[in] �t�@�C����
	" ********************************************************************************
	let file_ = call(s:File.get_files, a:000)[0]
	return perforce#pfDiff(file_)
endfunction
"}}}
function! perforce_2#revert(...) "{{{
	" ********************************************************************************
	" @param[in] �t�@�C����
	" ********************************************************************************
	let file_ = call(s:File.get_files, a:000)[0]
	let file_ = perforce#common#get_kk(file_)
	if perforce#is_p4_have(file_)
		let outs = perforce#pfcmds_new_outs('revert','',' -a '.file_)
	else
		let outs = perforce#pfcmds_new_outs('revert','',file_)
	endif
	call perforce#LogFile(outs)
endfunction 
"}}}
function! perforce_2#echo_error(message) "{{{
  echohl WarningMsg | echo a:message | echohl None
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
