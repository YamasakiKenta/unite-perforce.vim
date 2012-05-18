function! unite#sources#p4_change#define()
return [s:source_p4_changes_pending, s:source_p4_changes_submitted, s:source_p4_changes_pending_reopen]
endfunction

function! perforce#get_ChangeNum_from_changes(str) "{{{
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction "}}}
function! s:get_ClientName_from_changes(str) "{{{
	"-   Change 107 on 2012/01/21 by admin@admin_admin-PC_2014 *pending* 'client Change test '                                                                            
	let str = substitute(a:str,'\*pending\*','','') " # pending���܂܂�Ă�����폜
	return substitute(str, '.*change \d* on \d\d\d\d\/\d\d\/\d\d\ by .\{-}@\(.\{-}\) ''.*','\1','')
endfunction "}}}

" ********************************************************************************
" source - p4_changes_pending
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending',
			\ 'description' : '�쐬���̃`�F���W���X�g',
			\ 'is_quit' : 0,
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕\��
	" �`�F���W���X�g�̕ύX�̏ꍇ�A�J��������t�@�C����ύX���邩�Aaction�Ŏw�肵���t�@�C��
	" @param[in]	args				depot
	" @param[in]	action__path		�`�F���W���X�g�̕ύX�Ŏg�p	
	" ********************************************************************************

	" �\������N���C�A���g���̎擾
	let outs = g:pf_settings.client_changes_only.common ? 
				\ [perforce#get_PFCLIENTNAME()] : 
				\ perforce#pfcmds('clients','')

	" default�̕\��
	let rtn = []
	let rtn += map( outs, "{
				\ 'word' : 'default by '.perforce#get_ClientName_from_client(v:val),
				\ 'kind' : 'k_p4_change',
				\ 'action__chnum' : 'default',
				\ 'action__clname' : perforce#get_ClientName_from_client(v:val),
				\ 'action__path' : a:context.source__path,
				\ 'action__chname' : '',
				\ }")

	let outs = perforce#pfcmds('changes','','-s pending')
	let rtn += <SID>get_pfchanges(outs, 'k_p4_change')
	return rtn
endfunction "}}}
function! s:source.change_candidates(args, context) "{{{
	" ********************************************************************************
	" �V�K�쐬
	" ********************************************************************************

	" Unite �œ��͂��ꂽ����
	let newfile = a:context.input

	" ���͂��Ȃ��ꍇ�́A�\�����Ȃ�
	if newfile != ""
		return [{
					\ 'word' : '[new] '.newfile,
					\ 'kind' : 'k_p4_change',
					\ 'action__chnum' : 'new',
					\ 'action__chname' : newfile,
					\ 'action__clnum' : perforce#get_PFCLIENTNAME(),
					\ }]
	else
		return []
	endif

endfunction "}}}

let s:source_p4_changes_pending = s:source
unlet s:source

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : '�`�F���W���X�g�̈ړ�',
			\ 'hooks' : {},
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
"[ ] ��� gather_candidates �Ƃ܂Ƃ߂�
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕\��
	" �`�F���W���X�g�̕ύX�̏ꍇ�A�J��������t�@�C����ύX���邩�Aaction�Ŏw�肵���t�@�C��
	" @param[in]	args				depot
	" @param[in]	action__path		�`�F���W���X�g�̕ύX�Ŏg�p	
	" ********************************************************************************
	"
	" �\������N���C�A���g���̎擾
	let outs = g:pf_settings.client_changes_only.common ? 
				\ [perforce#get_PFCLIENTNAME()] : 
				\ perforce#pfcmds('clients','')

	" default�̕\��
	let rtn = []
	let rtn += map( outs, "{
				\ 'word' : 'default by '.perforce#get_ClientName_from_client(v:val),
				\ 'kind' : 'k_p4_change_reopen',
				\ 'action__chnum' : 'default',
				\ 'action__clname' : perforce#get_ClientName_from_client(v:val),
				\ 'action__path' : a:context.source__path,
				\ 'action__chname' : '',
				\ }")

	let outs = perforce#pfcmds('changes','','-s pending')
	let rtn += <SID>get_pfchanges(outs, 'k_p4_change_reopen')
	return rtn
endfunction "}}}
function! s:source.change_candidates(args, context) "{{{
	" ********************************************************************************
	" �V�K�쐬
	" ********************************************************************************

	" Unite �œ��͂��ꂽ����
	let newfile = a:context.input

	" ���͂��Ȃ��ꍇ�́A�\�����Ȃ�
	if newfile != ""
		return [{
					\ 'word' : '[new] '.newfile,
					\ 'kind' : 'k_p4_change_reopen',
					\ 'action__chnum' : 'new',
					\ 'action__chname' : newfile,
					\ 'action__clnum' : perforce#get_PFCLIENTNAME(),
					\ }]
	else
		return []
	endif

endfunction "}}}

let s:source_p4_changes_pending_reopen = s:source
unlet s:source 

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit �ς݃`�F���W���X�g',
			\ 'is_quit' : 0,
			\ }
function! s:source.gather_candidates(args, context) "{{{
	let outs = perforce#pfcmds('changes','','-s submitted')
	return <SID>get_pfchanges(outs, 'k_p4_change')
endfunction "}}}

let s:source_p4_changes_submitted = s:source
unlet s:source 

" ********************************************************************************
" subroutine
" ********************************************************************************
function! s:get_pfchanges(outs,kind) "{{{
	let outs = a:outs
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : a:kind,
				\ 'action__chnum' : perforce#get_ChangeNum_from_changes(v:val),
				\ 'action__chname' : '',
				\ 'action__clname' : <SID>get_ClientName_from_changes(v:val),
				\ 'action__port' : $PFPORT,
				\ }")

	return candidates
endfunction "}}}

