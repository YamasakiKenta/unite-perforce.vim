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

" ********************************************************************************
" source - p4_changes_pending
" ********************************************************************************
let s:source = {
			\ 'name'        : 'p4_changes_pending',
			\ 'description' : '�쐬���̃`�F���W���X�g',
			\ 'hooks'       : {},
			\ 'is_quit'     : 0,
			\ }
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" �`�F���W���X�g�̕\�� �\���ݒ�֐�
	" �`�F���W���X�g�̕ύX�̏ꍇ�A�J��������t�@�C����ύX���邩�Aaction�Ŏw�肵���t�@�C��
	" @param[in]	args				depot
	" ********************************************************************************
	"
	" �\������N���C�A���g���̎擾
	let outs = perforce#data#get('client_changes_only') ? 
				\ [perforce#get_PFCLIENTNAME()] : 
				\ perforce#pfcmds('clients','').outs

				"\ 'word'           : 'default by '.perforce#get_ClientName_from_client(v:val),
	" default�̕\��
	let rtn = []
	let rtn += map( outs, "{
				\ 'word'           : 'default by '.v:val,
				\ 'kind'           : 'k_p4_change_pending',
				\ 'action__chnum'  : 'default',
				\ 'action__depots' : a:context.source__depots,
				\ }")

	let outs = perforce#pfcmds('changes','','-s pending').outs
	let rtn += perforce#get_pfchanges(a:context, outs, 'k_p4_change_pending')
	return rtn
endfunction "}}}
function! s:source.change_candidates(args, context) "{{{
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

endfunction "}}}

let s:source_p4_changes_pending = deepcopy(s:source) | unlet s:source

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : '�`�F���W���X�g�̈ړ�',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4_change_reopen',
			\ }
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
let s:source.gather_candidates = s:source_p4_changes_pending.gather_candidates
let s:source.change_candidates = s:source_p4_changes_pending.change_candidates

let s:source_p4_changes_pending_reopen = deepcopy(s:source) | unlet s:source 

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit �ς݃`�F���W���X�g',
			\ 'hooks' : {},
			\' default_action' : 'a_p4change_describe',
			\ }

	"call unite#start_temporary([['settings_ex_list_select', tmp_d]], {'default_action' : 'a_toggle'})
let s:source.hooks.on_init = function('perforce#get_filename_for_unite')
function! s:source.gather_candidates(args, context) "{{{
	let outs = perforce#pfcmds('changes','','-s submitted').outs
	return perforce#get_pfchanges(a:context, outs, 'k_p4_change_submitted')
endfunction "}}}

let s:source_p4_changes_submitted = deepcopy(s:source) | unlet s:source

call unite#define_source(s:source_p4_changes_pending_reopen)
call unite#define_source(s:source_p4_changes_submitted)
call unite#define_source(s:source_p4_changes_pending)


let &cpo = s:save_cpo
unlet s:save_cpo

