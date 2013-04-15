let s:save_cpo = &cpo
set cpo&vim

let g:perforce_merge_tool         = get(g:, 'perforce_merge_tool', 'winmergeu /S')
let g:perforce_merge_default_path = get(g:, 'perforce_merge_default_path', 'c:\tmp')

function! perforce_2#common_action_out(outs)
	" ********************************************************************************
	" @par       action �I�����ɌĂяo��
	" @param[in] ���s���� ( Log �ŕ\�����镶���� ) 
	" @retval    
	" ********************************************************************************
		call perforce#LogFile(a:outs)
		"call unite#force_redraw()
endfunction
function! perforce_2#complate_have(A,L,P) "{{{
	"********************************************************************************
	" �⊮ : perforce ��ɑ��݂���t�@�C����\������
	"********************************************************************************
	let outs = split(system('p4 have //.../'.a:A.'...'), "\n")
	return map( copy(outs), "
				\ matchstr(v:val, '.*/\\zs.\\{-}\\ze\\#')
				\ ")
endfunction
"}}}
function! perforce_2#edit_add(add_flg, ...) "{{{
	" ********************************************************************************
	" �ҏW��ԁA�������͒ǉ���Ԃɂ���
	" @param[in] a:add_flg = 1 - TREUE : �N���C�A���g�ɑ��݂��Ȃ��ꍇ�́A�t�@�C����ǉ�
	" @param[in] a:000     {�t�@�C����}     �l���Ȃ��ꍇ�́A���݂̃t�@�C����ҏW����
	" ********************************************************************************
	"
	" �ҏW����t�@�C�ږ��̎擾
	let _files = call('perforce#util#get_files', a:000)

	" init
	let files_d = {
				\ 'add'  : [],
				\ 'edit' : [],
				\ }

	" �O���[�v�̕���
	let data_d = perforce#is_p4_haves(_files)

	let files_d['edit']  = data_d.true

	if ( a:add_flg == 1 )
		let files_d['add']   = data_d.false
	endif

	" �R�}���h�����s����
	let outs = []
	for cmd in keys(files_d)
		let files_ = files_d[cmd]
		if len(files_) > 0
			call extend(outs, perforce#cmd#files_outs(cmd, files_))
		endif
	endfor

	" ���O�̕\��
	call perforce#LogFile(outs)
endfunction
"}}}
function! perforce_2#revert(...) "{{{
	" ********************************************************************************
	" @param[in] �t�@�C����
	" ********************************************************************************
	let files_ = call('perforce#util#get_files', a:000)

	" �� edit ,add ���܂˂�

	let data_d = perforce#is_p4_haves(files_)
	" ���܂Ƃ߂�
	let outs = perforce#cmd#files_outs('revert -a', data_d.true)
	let outs = perforce#cmd#files_outs('revert', data_d.false)

	call perforce#LogFile(outs)
endfunction 
"}}}
function! perforce_2#echo_error(message) "{{{
  echohl WarningMsg 
  echo a:message 
  echohl None
endfunction
"}}}
function! perforce_2#pf_merge(...) "{{{
	" ********************************************************************************
	" ���݂̃N���C�A���g�ƁA�}�[�W���܂��B
	" @param[in]	path	��r����t�@�C��
	" @retval       NONE
	" ********************************************************************************
	let path = ( a:1 == "" ) ? g:perforce_merge_default_path : a:1

	" �� �f�t�H���g�ɂȂ��Ă��邪�A��������ꍇ�͂ǂ����邩
	" �� �����Œǉ�����t���O��ݒ肷��
	let port = substitute(perforce#get#PFPORT(), ':', '', 'g')
	
	let path = path.'/new/'.port

	let cmd = g:perforce_merge_tool.' "'.path.'" "'.perforce#get#PFCLIENTPATH().'"'

	exe '!start '.cmd

endfunction
"}}}
function! perforce_2#show(str)
	call perforce#common#LogFile('p4show', 1, a:str)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
