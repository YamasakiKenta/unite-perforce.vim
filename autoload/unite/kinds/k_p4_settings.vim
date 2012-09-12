function! unite#kinds#k_p4_settings#define()
	return [s:k_p4_settings_bool, s:k_p4_settings_strs, s:k_p4_select]
endfunction

" �I���֐�
function! s:common_out() "{{{
	call perforce#data#save($PFDATA)
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
			\ 'description' : '�ݒ�̐ؑ�',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{

	for candidate in a:candidates	
		let name = candidate.action__valname
		let kind = candidate.action__kind
		call perforce#data#set(name, kind, 1-perforce#data#get(name, kind))
	endfor

	" �\���̍X�V
	call s:common_out()
endfunction "}}}

let s:kind.action_table.a_set_enable = {
			\ 'description' : '�L���ɂ���',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_enable.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let kind = candidate.action__kind
		call perforce#data#set(name, kind, 1)
	endfor
	call s:common_out()
endfunction "}}}

let s:kind.action_table.a_set_disable = {
			\ 'description' : '�����ɂ���',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_disable.func(candidates) "{{{
	for candidate in a:candidates	
		let name = candidate.action__valname
		let kind = candidate.action__kind
		let perforce#data#set(name, kind, 0)
	endfor
	call s:common_out()
endfunction "}}}

let s:k_p4_settings_bool = s:kind
unlet s:kind

" ********************************************************************************
" kind - k_p4_settings_strs
" ********************************************************************************
let s:kind = { 
			\ 'name' : 'k_p4_settings_strs',
			\ 'default_action' : 'a_toggles',
			\ 'action_table' : {},
			\ 'parents' : ['k_p4'],
			\ }

let s:kind.action_table.a_toggle = {
			\ 'description' : '�ݒ�̐ؑ�',
			\ 'is_selectable' : 1,
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{

	for candidate in a:candidates
		let name = candidate.action__valname
		let kind = candidate.action__kind

		" �����̕\��
		let len  = len(perforce#data#set(name, kind, - 1))
		let max  = float2nr(pow(2, len))

		let val = perforce#data#get(name, kind)[0] * 2 

		" ����ł��Ȃ��ꍇ
		if val < 1 || val >= max 
			let val = 1
		endif

		let perforce#data#set( name, kind,  val)

	endfor
	call s:common_out()


endfunction "}}}

let s:kind.action_table.a_toggles = {
			\ 'description' : '�����I��',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_toggles.func(candidate) "{{{

	" todo : unite source �ŕ����I��������
	let name = a:candidate.action__valname
	let kind = a:candidate.action__kind

	call unite#start_temporary([['p4_select', {'name' : name, 'kind' : kind}]])

	" call s:common_out()
endfunction "}}}

let s:kind.action_table.a_set_strs = {
			\ 'description' : '���O�̓o�^ ( ���X�g ) ',
			\ 'is_quit' : 0,
			\ }
function! s:kind.action_table.a_set_strs.func(candidate) "{{{
	let name = a:candidate.action__valname
	let kind = a:candidate.action__kind
	let tmp = input("",string(perforce#data#get_orig(name, kind)))

	if tmp != ""
		exe 'let tmp_dict = '.tmp
		call perforce#data#set(name, kind, tmp_dict)
	endif

	call s:common_out()

	call unite#force_quit_session()

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
			\ 'description' : '�ݒ�̐ؑ�',
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.a_toggle.func(candidates) "{{{
	let val = 0
	for candidate in a:candidates
		let val += candidate.action__bitnum
	endfor

	let name = a:candidates[0].action__name
	let kind = a:candidates[0].action__kind

	call perforce#data#set_bits_orig(name, kind, val)
	
	call unite#force_quit_session()

	call s:common_out()

endfunction "}}}

let s:kind.action_table.delete = {
			\ 'description' : 'delete',
			\ 'is_selectable' : 1,
			\ }
function! s:kind.action_table.delete.func(candidates) "{{{

	" ������
	let nums = []
	for candidate in a:candidates
		call add(nums, candidate.action__num)
	endfor

	" ���ނ̂݌���̂���
	let name = a:candidates[0].action__name
	let kind = a:candidates[0].action__kind

	" �폜����
	call perforce#data#delte(name, kind, nums)

	call unite#force_quit_session()
	call s:common_out()

endfunction "}}}

let s:k_p4_select = s:kind
unlet s:kind

