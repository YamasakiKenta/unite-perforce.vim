function! unite#kinds#k_p4_settings#define()
	return [s:k_p4_settings_bool, s:k_p4_settings_str, s:k_p4_settings_strs]
endfunction

" 終了関数
function! s:out() "{{{
	call unite#force_redraw()
	call perforce#save($PFDATA)
endfunction "}}}

let s:kind = { 
			\ 'name' : 'k_p4_settings_bool',
			\ 'default_action' : 'a_toggle',
			\ 'action_table' : {},
			\ }

let s:kind.action_table.a_toggle = {
			\ 'is_selectable' : 1,
			\ 'description' : '現在の設定を反転させる',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let g:pf_setting.bool[name].value = 1 - g:pf_setting.bool[name].value
	endfor

	" 表示の更新
	call <SID>out()
endfunction "}}}

let s:kind.action_table.a_set_enable = {
			\ 'is_selectable' : 1,
			\ 'description' : '有効にする',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_enable.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let g:pf_setting.bool[name].value = 1
	endfor
	call <SID>out()
endfunction "}}}

let s:kind.action_table.a_set_disable = {
			\ 'is_selectable' : 1,
			\ 'description' : '無効にする',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_disable.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let g:pf_setting.bool[name].value = 0
	endfor
	call <SID>out()
endfunction "}}}

let s:k_p4_settings_bool = s:kind
unlet s:kind

let s:kind = { 
			\ 'name' : 'k_p4_settings_str',
			\ 'default_action' : 'a_set_str',
			\ 'action_table' : {},
			\ }

let s:kind.action_table.a_set_str = {
			\ 'description' : '名前の登録',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_str.func(candidate) "{{{
	let name = a:candidate.action__valname
	let tmp = input('new '.name.' > ',g:pf_setting.str[name].value)
	if tmp != ""
		let g:pf_setting.str[name].value = tmp
	endif
	call <SID>out()
endfunction "}}}

let s:k_p4_settings_str = s:kind
unlet s:kind

let s:kind = { 
			\ 'name' : 'k_p4_settings_strs',
			\ 'default_action' : 'a_set_strs',
			\ 'action_table' : {},
			\ }

let s:kind.action_table.a_set_strs = {
			\ 'description' : '名前の登録',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_strs.func(candidate) "{{{
	let name = a:candidate.action__valname
	let tmp = input('new '.name.'(list) > ',g:pf_setting.str[name].value)
	if tmp != ""
		let g:pf_setting.str[name].value = split(tmp)
	endif
	call <SID>out()
endfunction "}}}

let s:k_p4_settings_strs = s:kind
unlet s:kind
