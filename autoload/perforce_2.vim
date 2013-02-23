let s:save_cpo = &cpo
set cpo&vim

if 1
	let s:L = vital#of('unite-perforce.vim')
	let s:File = s:L.import('Mind.Y_files')
else
	function! s:get_files(...) "{{{
		return get(a:, 1, "") == "" ? [expand("%:p")] : a:000
	endfunction
	"}}}
	let s:File = {}
	let s:File.get_files = function('s:get_files')
endif



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
	let file_ = call(s:File.get_files, a:000)[0]
	return perforce#pfDiff(file_)
endfunction
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
