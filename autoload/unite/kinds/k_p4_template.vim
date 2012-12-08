let s:save_cpo = &cpo
set cpo&vim
function! unite#kinds#k_p4_template#define()
	return [s:kind_p4_template]
endfunction
"kind - k_p4_template
let s:kind = {
	\ 'name'           : 'k_p4_template',
	\ 'description'    : 'テンプレートから設定します',
	\ 'action_table'   : {},
	\ 'default_action' : 'update_',
	\ 'parents'        : [],
	\ }
call unite#define_kind(s:kind) 
let s:kind.action_table.update_ = {
			\ 'is_selectable' : 1, 
			\ 'description' : '',
			\ }
function! s:kind.action_table.update_.func(candidates) "{{{
	for candidate in a:candidates
		let tmp    = candidate.action__tmp
		let clname = candidate.action__clname
		let port   = candidate.action__port
		let cmd = 'p4 -p '.port.' client -o -t '.tmp.' '.clname.' | p4 client -i'
		"call system(cmd)
		exe '!'.cmd
	endfor
endfunction "}}}

let s:kind.action_table.info = {
	\ 'is_selectable' : 1,
	\ 'description'   : '説明を表示します',
	\ }
function! s:kind.action_table.info.func(candidates)
	for candidate in a:candidates
	endfor
endfunction

let s:kind_p4_template = deepcopy(s:kind)
let &cpo = s:save_cpo
unlet s:save_cpo
