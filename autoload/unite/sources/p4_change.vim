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
function! s:get_pfchanges(context,data_ds) "{{{
	" ********************************************************************************
	" @par          p4_changes Untie �p�� �Ԃ�l��Ԃ�
	" @param[in]	context
	" @param[in]	data_ds
	" ********************************************************************************
	let candidates = []
	for data_d in a:data_ds
		let client = data_d.client
		for out in data_d.outs
			call add( candidates, {
						\ 'word'           : client.' : '.out,
						\ 'action__chnum'  : s:get_ChangeNum_from_changes(out),
						\ 'action__client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endfor

	return candidates
endfunction
"}}}

" ********************************************************************************
" source - p4_changes_pending
" ********************************************************************************
let s:source_p4_changes_pending = {
			\ 'name'         : 'p4_changes_pending',
			\ 'description'  : '�쐬���̃`�F���W���X�g',
			\ 'hooks'        : {},
			\ 'default_kind' : 'k_p4_change_pending',
			\ 'is_quit'      : 0,
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
	let clients = perforce#data#get('g:unite_perforce_clients')

	" default�̕\��
	let rtn = []
	let rtn += map( clients, "{
				\ 'word'           : 'default by '.v:val,
				\ 'kind'           : 'k_p4_change_pending',
				\ 'action__chnum'  : 'default',
				\ 'action__client' : v:val,
				\ 'action__depots' : a:context.source__depots,
				\ }")

	let data_ds = perforce#cmd#new('changes','','-s pending')
	let rtn += s:get_pfchanges(a:context, data_ds)
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
	let candidates = []

	" ���͂��Ȃ��ꍇ�́A�\�����Ȃ�
	if newfile != ""
		let clients = perforce#data#get('g:unite_perforce_clients')
		for client in clients
			call add(candidates, {
						\ 'word' : '[new] '.client.' : '.newfile,
						\ 'kind' : 'k_p4_change_reopen',
						\ 'action__chname' : newfile,
						\ 'action__chnum' : 'new',
						\ 'action_client' : client,
						\ 'action__depots' : a:context.source__depots,
						\ })
		endfor
	endif

	return candidates

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
			\ 'default_action' : 'a_p4change_describe',
			\ 'default_kind' : 'k_p4_change_submitted',
			\ }

	"call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
let s:source_p4_changes_submitted.hooks.on_init = function('perforce#get#fname#for_unite')
function! s:source_p4_changes_submitted.gather_candidates(args, context) "{{{
	let data_ds = perforce#cmd#new('changes','','-s submitted')
	return s:get_pfchanges(a:context, data_ds)
endfunction
"}}}

call unite#define_source(s:source_p4_changes_pending_reopen)
call unite#define_source(s:source_p4_changes_submitted)
call unite#define_source(s:source_p4_changes_pending)


let &cpo = s:save_cpo
unlet s:save_cpo

