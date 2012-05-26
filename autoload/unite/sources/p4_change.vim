function! unite#sources#p4_change#define()
	return [s:source_p4_changes_pending, s:source_p4_changes_submitted, s:source_p4_changes_pending_reopen]
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
			\ 'name' : 'p4_changes_pending',
			\ 'description' : '�쐬���̃`�F���W���X�g',
			\ 'hooks' : {},
			\ 'is_quit' : 0,
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
let s:source.gather_candidates = function('perforce#p4_change_gather_candidates')
let s:source.change_candidates = function('perforce#p4_change_change_candidates')

let s:source_p4_changes_pending = s:source
unlet s:source

" ********************************************************************************
" source - p4_changes_pending_reopen
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_pending_reopen',
			\ 'description' : '�`�F���W���X�g�̈ړ�',
			\ 'hooks' : {},
			\ 'default_action' : 'a_p4_change_reopen',
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
let s:source.gather_candidates = function('perforce#p4_change_gather_candidates')
let s:source.change_candidates = function('perforce#p4_change_change_candidates')

let s:source_p4_changes_pending_reopen = s:source
unlet s:source 

" ********************************************************************************
" source - p4_changes_submitted
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_changes_submitted',
			\ 'description' : 'submit �ς݃`�F���W���X�g',
			\ 'hooks' : {},
			\ 'is_quit' : 0,
			\ }
let s:source.hooks.on_init = function('perforce#GetFileNameForUnite')
function! s:source.gather_candidates(args, context) "{{{
	let outs = perforce#pfcmds('changes','','-s submitted')
	return perforce#get_pfchanges(a:context, outs, 'k_p4_change')
endfunction "}}}
let s:source_p4_changes_submitted = s:source
unlet s:source 
