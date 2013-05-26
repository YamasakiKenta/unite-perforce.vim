let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_change#define()
	return s:source_p4_changes_pending
endfunction
" --------------------------------------------------------------------------------
" �\���ύX
" action__chname	�V�K�`�F���W���X�g�̃R�����g
" action__chnum		�`�F���W���X�g�̔ԍ�
" action__depots	�`�F���W���X�g�̕ύX ( �ҏW����t�@�C�� ) 
" --------------------------------------------------------------------------------

let s:source_p4_changes_pending = {
			\ 'name'         : 'p4_changes_pending',
			\ 'description'  : '�쐬���̃`�F���W���X�g',
			\ 'default_kind' : 'k_p4_change_pending',
			\ 'hooks'        : {},
			\ 'is_quit'      : 0,
			\ }
let s:source_p4_changes_pending.hooks.on_init     = function('perforce#get#fname#for_unite')
let s:source_p4_changes_pending.gather_candidates = function('pf_changes#gather_candidates')
let s:source_p4_changes_pending.change_candidates = function('pf_changes#change_candidates')

call unite#define_source(s:source_p4_changes_pending)

let &cpo = s:save_cpo
unlet s:save_cpo

