let s:save_cpo = &cpo
set cpo&vim

command! -complete=customlist,Pf_complate_have -nargs=1 PfFind call perforce#pfFind(<f-args>)
function! Pf_complate_have(A,L,P) "{{{
	"********************************************************************************
	" �⊮ : perforce ��ɑ��݂���t�@�C����\������
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction "}}}

command! -nargs=+ MatomeDiffs call perforce#matomeDiffs(<f-args>)

command! GetClientName call perforce#get_client_data_from_info()

function! s:pf_edit_add(add_flg, ...) "{{{
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
command! -narg=* PfEdit call s:pf_edit_add(0, <f-args>)
command! -narg=* PfAdd call s:pf_edit_add(1, <f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

