function! unite#kinds#k_null#define()
	return s:kind
endfunction

let s:kind = { 'name' : 'k_null',
			\ 'default_action' : 'a_null',
			\ 'action_table' : {},
			\ 'is_quit' : 0,
			\ }

let s:kind.action_table.a_null = {
			\ 'description' : '�Ȃɂ����Ȃ�',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_null.func(candidate) "{{{
endfunction "}}}
