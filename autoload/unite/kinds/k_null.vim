let s:save_cpo = &cpo
set cpo&vim


function! unite#kinds#k_null#define()
	return s:kind
endfunction

" p4_settings.vim �Ŏg�p����
let s:kind = { 
			\ 'name'           : 'k_null',
			\ 'default_action' : 'a_null',
			\ 'action_table'   : {},
			\ 'is_quit'        : 0,
			\ }

let s:kind.action_table.a_null = {
			\ 'description' : '�Ȃɂ����Ȃ�',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_null.func(candidate) "{{{
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

