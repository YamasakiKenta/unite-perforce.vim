let s:save_cpo = &cpo
set cpo&vim

let s:Tab = vital#of('unite-perforce.vim').import('Mind.Tab')
function! unite#kinds#k_p4_template#define()
	return [s:kind_p4_template]
endfunction
"kind - k_p4_template
let s:kind = {
	\ 'name'           : 'k_p4_template',
	\ 'description'    : 'テンプレートから設定します',
	\ 'action_table'   : {},
	\ 'default_action' : 'info',
	\ 'parents'        : ['common'],
	\ }
call unite#define_kind(s:kind) 
let s:kind.action_table.update_ = {
			\ 'is_selectable' : 1, 
			\ 'description' : '',
			\ }
function! s:kind.action_table.update_.func(candidates) "{{{
	for candidate in a:candidates
		let tmp    = candidate.action__cltmp
		let clname = candidate.action__clname
		let port   = candidate.action__port
		let cmd = 'p4 -p '.port.' client -o -t '.tmp.' '.clname.' | p4 client -i'
		call system(cmd)
	endfor
endfunction "}}}

let s:kind.action_table.info = {
	\ 'is_selectable' : 1,
	\ 'description'   : '説明を表示します',
	\ }
function! s:kind.action_table.info.func(candidates) "{{{
	let datas = []
	echo a:candidates
	for candidate in a:candidates
		let tmp    = candidate.action__cltmp
		let clname = candidate.action__clname
		let port   = candidate.action__port
		let outs = perforce#pfcmds('info', '-p '.port.' -c '.clname).outs
		call add(datas, outs)
	endfor

	call s:Tab.open_lines(datas)
endfunction "}}}

let s:kind_p4_template = deepcopy(s:kind)
call unite#define_kind(s:kind_p4_template)
let &cpo = s:save_cpo
unlet s:save_cpo
