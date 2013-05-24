let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_template#define()
	return [s:kind_p4_template]
endfunction
"kind - k_p4_template
let s:kind = {
	\ 'name'           : 'k_p4_template',
	\ 'default_action' : 'a_info',
	\ 'description'    : 'テンプレートから設定します',
	\ 'action_table'   : {},
	\ 'parents'        : ['common'],
	\ }
"call unite#define_kind(s:kind) 
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
endfunction
"}}}

let s:kind.action_table.a_info = {
	\ 'is_selectable' : 1,
	\ 'description'   : '説明を表示します',
	\ }
function! s:kind.action_table.a_info.func(candidates) "{{{

	for candidate in a:candidates
		let datas = []
		let cltmp  = candidate.action__cltmp
		let clname = candidate.action__clname
		let port   = candidate.action__port

		let outs = perforce#cmd#base('client', '-p '.port.' -c '.clname, '-o').outs
		call add(datas, outs)

		let outs = perforce#cmd#base('client', '-p '.port.' -c '.cltmp, '-o').outs
		call add(datas, outs)

		call perforce#util#open_lines(datas)

		windo diffthis
	endfor
	
endfunction
"}}}

let s:kind_p4_template = deepcopy(s:kind)
call unite#define_kind(s:kind_p4_template)
let &cpo = s:save_cpo
unlet s:save_cpo
