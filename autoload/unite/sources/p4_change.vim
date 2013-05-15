let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_change#define()
	return [
				\ s:source_p4_changes_pending,
				\ s:source_p4_changes_submitted,
				\ s:source_p4_changes_pending_reopen,
				\ ]
endfunction
" --------------------------------------------------------------------------------
" �\���ύX
" action__chname	�V�K�`�F���W���X�g�̃R�����g
" action__chnum		�`�F���W���X�g�̔ԍ�
" action__depots	�`�F���W���X�g�̕ύX ( �ҏW����t�@�C�� ) 
" --------------------------------------------------------------------------------
"
function! s:get_ChangeNum_from_changes(str) 
	return substitute(a:str, '.*change \(\d\+\).*', '\1','')
endfunction
function! s:get_pfchanges(context,outs,kind) "{{{
	" ********************************************************************************
	" @par          p4_changes Untie �p�� �Ԃ�l��Ԃ�
	" @param[in]	context
	" @param[in]	outs
	" @param[in]	kind	
	" ********************************************************************************
	let outs = a:outs
	let candidates = map( outs, "{
				\ 'word'           : v:val,
				\ 'kind'           : a:kind,
				\ 'action__chnum'  : s:get_ChangeNum_from_changes(v:val),
				\ 'action__depots' : a:context.source__depots,
				\ }")

	return candidates
endfunction
"}}}
function! s:get_client_from_clients_cmd(str)
	return ''
endfunction

" ********************************************************************************
" source - p4_changes_pending
" ********************************************************************************
let s:source_p4_changes_pending = {
			\ 'name'        : 'p4_changes_pending',
			\ 'description' : '�쐬���̃`�F���W���X�g',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source_p4_changes_pending.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_pending.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕\�� �\���ݒ�֐�
	" �`�F���W���X�g�̕ύX�̏ꍇ�A�J��������t�@�C����ύX���邩�Aaction�Ŏw�肵���t�@�C��
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" �\������N���C�A���g���̎擾
	let origin_clients = perforce#data#get('g:unite_perforce_clients')

	if perforce#data#get('g:unite_perforce_client_changes_only') == 1
		let clients = origin_clients
	else
		let port = map(cpy(clients), 'matchstr('-p\s\+\w*')
	endif

	echo clients 

	" default�̕\��
	let rtn = []
	let rtn += map( clients, "{
				\ 'word'           : 'default by '.v:val,
				\ 'kind'           : 'k_p4_change_pending',
				\ 'action__chnum'  : 'default',
				\ 'action__client' : v:val,
				\ 'action__depots' : a:context.source__depots,
				\ }")

	let outs = perforce#cmd#base('changes','','-s pending').outs
	let rtn += s:get_pfchanges(a:context, outs, 'k_p4_change_pending')
	return rtn
endfunction
"}}}
function! s:source_p4_changes_pending.change_candidates(args, context) "{{{
	" ********************************************************************************
	" p4 change �\�[�X�� �ω��֐�
	" @param[in]	
	" @retval       
	" ********************************************************************************
	" Unite �œ��͂��ꂽ����
	let newfile = a:context.input

	" ���͂��Ȃ��ꍇ�́A�\�����Ȃ�
	if newfile != ""
		return [{
					\ 'word' : '[new] '.newfile,
					\ 'kind' : 'k_p4_change_reopen',
					\ 'action__chname' : newfile,
					\ 'action__chnum' : 'new',
					\ 'action__depots' : a:context.source__depots,
					\ }]
	else
		return []
	endif

endfunction
"}}}

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source_p4_changes_pending_reopen = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : '�`�F���W���X�g�̈ړ�',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4_change_reopen',
			\ }
let s:source_p4_changes_pending_reopen.hooks.on_init = function('perforce#get#fname#for_unite')
let s:source_p4_changes_pending_reopen.gather_candidates = s:source_p4_changes_pending.gather_candidates
let s:source_p4_changes_pending_reopen.change_candidates = s:source_p4_changes_pending.change_candidates

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source_p4_changes_submitted = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit �ς݃`�F���W���X�g',
			\ 'hooks' : {},
			\' default_action' : 'a_p4change_describe',
			\ }

	"call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
let s:source_p4_changes_submitted.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_submitted.gather_candidates(args, context) "{{{
	let outs = perforce#cmd#base('changes','','-s submitted').outs
	return s:get_pfchanges(a:context, outs, 'k_p4_change_submitted')
endfunction
"}}}

call unite#define_source(s:source_p4_changes_pending_reopen)
call unite#define_source(s:source_p4_changes_submitted)
call unite#define_source(s:source_p4_changes_pending)


let &cpo = s:save_cpo
unlet s:save_cpo

