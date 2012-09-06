function! unite#kinds#k_p4_settings#define()
	return [s:k_p4_settings_bool, s:k_p4_settings_strs, s:k_p4_select]
endfunction

" 終了関数
function! s:common_out() "{{{
	call perforce#setting#save($PFDATA)
	call unite#force_redraw()
endfunction "}}}

" ********************************************************************************
" kind - k_p4_settings_bool
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_settings_bool',
			\ 'default_action' : 'a_toggle',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_toggle = {
			\ 'description' : '設定の切替',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{

	for candidate in a:candidates	
		let name = candidate.action__valname
		let kind = candidate.action__kind
		let g:pf_settings[name][kind] = 1 - perforce#setting#get(name, kind).datas
	endfor

	" 表示の更新
	call <SID>common_out()
endfunction "}}}

let s:kind.action_table.a_set_enable = {
			\ 'description' : '有効にする',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_enable.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let kind = candidate.action__kind
		let g:pf_settings.name][kind] = 1
	endfor
	call <SID>common_out()
endfunction "}}}

let s:kind.action_table.a_set_disable = {
			\ 'description' : '無効にする',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_disable.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let kind = candidate.action__kind
		let g:pf_settings.name][kin] = 0
	endfor
	call <SID>common_out()
endfunction "}}}

let s:k_p4_settings_bool = s:kind
unlet s:kind

" ********************************************************************************
" kind - k_p4_settings_strs
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_settings_strs',
			\ 'default_action' : 'a_toggle',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_toggle = {
			\ 'description' : '設定の切替',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{

	for candidate in a:candidates
		let name = candidate.action__valname
		let kind = candidate.action__kind

		" 文字の表示
		let len  = len(g:pf_settings[name][kind]) - 1
		let max  = float2nr(pow(2, len))

		let val = g:pf_settings[name][kind][0] * 2 

		" 判定できない場合
		if val < 1 || val >= max 
			let val = 1
		endif

		let g:pf_settings[name][kind][0] = val

	endfor
	call <SID>common_out()


endfunction "}}}

let s:kind.action_table.a_toggles = {
			\ 'description' : '複数選択',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggles.func(candidate) "{{{

	" todo : unite source で複数選択をする
	let name = a:candidate.action__valname
	let kind = a:candidate.action__kind

	call unite#start_temporary([['p4_select', {'name' : name, 'kind' : kind}]])

	" call <SID>common_out()
endfunction "}}}

let s:kind.action_table.a_set_strs = {
			\ 'description' : '名前の登録 ( リスト ) ',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_strs.func(candidate) "{{{
	let name = a:candidate.action__valname
	let kind = a:candidate.action__kind
	let tmp = input("",string(g:pf_settings[name][kind]))

	if tmp != ""
		exe 'let g:pf_settings[name][kind] = '.tmp
	endif

	call <SID>common_out()
endfunction "}}}

let s:k_p4_settings_strs = s:kind
unlet s:kind

" ********************************************************************************
" kind - k_p4_select
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_select',
			\ 'default_action' : 'a_toggle',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_toggle = {
			\ 'description' : '設定の切替',
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{
	let val = 0
	for candidate in a:candidates
		let val += candidate.action__bitnum
	endfor

	let name = a:candidates[0].action__name
	let kind = a:candidates[0].action__kind
	let g:pf_settings[name][kind][0] = val
	
	call <SID>common_out()

	" 開きなおす
	call unite#start([['p4_settings', kind]])
endfunction "}}}

let s:k_p4_select = s:kind
unlet s:kind

