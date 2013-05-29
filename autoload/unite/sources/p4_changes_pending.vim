let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_changes_pending#define()
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

function! s:source_p4_changes_pending.hooks.on_init(...)
	return call('perforce#get#fname#for_unite', a:000)
endfunction

function! s:source_p4_changes_pending.gather_candidates(...)
	return call('pf_changes#gather_candidates', a:000 + ['pending'])
endfunction

function! s:source_p4_changes_pending.change_candidates(...)
return call('pf_changes#change_candidates', a:000)
endfunction

call unite#define_source(s:source_p4_changes_pending)

let &cpo = s:save_cpo
unlet s:save_cpo

