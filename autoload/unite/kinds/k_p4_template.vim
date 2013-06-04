let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#k_p4_template#define()
	return s:kind_p4_template
endfunction

let s:kind_p4_template = {
	\ 'name'           : 'k_p4_template',
	\ 'default_action' : 'a_info',
	\ 'description'    : 'テンプレートから設定します',
	\ 'action_table'   : {},
	\ 'parents'        : ['common'],
	\ }
let s:kind_p4_template.action_table.update_ = {
			\ 'is_selectable' : 1, 
			\ 'description' : '',
			\ }
function! s:kind_p4_template.action_table.update_.func(candidates) "{{{
	for candidate in a:candidates
		let tmp    = candidate.action__cltmp
		let client = s:get_client(candidate.action__clname)
		let clname = s:get_clname(candidate.action__clname)
		" ★ port , client を考慮する
		let cmd = 'p4 '.client.' client -o -t '.tmp.' '.clname.' | p4 '.client.' client -i'
		call unite#print_message(cmd)
		call system(cmd)
	endfor
endfunction
"}}}
let s:kind_p4_template.action_table.a_info = {
	\ 'is_selectable' : 1,
	\ 'description'   : '説明を表示します',
	\ }
function! s:kind_p4_template.action_table.a_info.func(candidates) "{{{

	for candidate in a:candidates
		let datas = []
		let cltmp  = candidate.action__cltmp

		let port   = s:get_port(candidate.action__clname)
		let client = s:get_client(candidate.action__clname)
		let clname = s:get_clname(candidate.action__clname)

		let cmds = []

		" メイン
		let cmd = 'p4 '.port.' client -o '.clname
		call add(cmds, cmd)
		let outs = split(system(cmd), "\n")
		call add(datas, outs)

		" teamplte
		let cmd = 'p4 '.port.' client -o '.cltmp
		call add(cmds, cmd)
		let outs = split(system(cmd), "\n")
		call add(datas, outs)

		" windows の表示
		call perforce#util#open_lines(datas)

		for num_ in range(len(cmds))
			exe ''.(1+num_).'wincmd w'
			let str = 'perforce::'.cmds[num_]
			let str = substitute(str, ' ', '\\ ', 'g')

			exe 'setl stl='.str
			setl noma
			setl nobuflisted
			norm zR
		endfor

		windo diffthis
	endfor
	
endfunction
"}}}

" === SUB ===
" autoload 関数化
function! s:get_client(str)  "{{{

	" clname
	if a:str =~ '-c\s\+'
		let clname    = matchstr(a:str, '-c\s\+\w\+')
	else
		let clname  = '-c '.substitute(a:str, '-p\s\+', '', '')
	endif

	"port
	let port    = matchstr(a:str, '-p\s\+\w\+')

	return port.' '.clname
endfunction
"}}}
function! s:get_clname(str) "{{{
	let clname = a:str

	if clname =~ '-p\s\+'
		let clname = substitute(clname, '-p\s\+\w\+', '', '')
	endif

	if clname =~ '-c\s\+'
		let clname = substitute(clname, '-c', '', '')
	endif
	return clname
endfunction
"}}}
function! s:get_port(str) "{{{

	if a:str =~ '-p\s\+'
		let port = substitute(a:str, '-p\s\+\w\+', '', '')
	else
		let port = ''
	endif

	return port
endfunction
"}}}

call unite#define_kind(s:kind_p4_template)

let &cpo = s:save_cpo
unlet s:save_cpo
