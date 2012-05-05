function! unite#sources#p4_settings#define()
	return [s:source_p4_select, s:source_p4_settings]
endfunction

let s:source = {
			\ 'name' : 'p4_settings',
			\ 'description' : 'unite-perforce.vim �̐ݒ�',
			\ 'is_quit' : 0,
			\ 'hooks' : {},
			\ 'syntax' : 'uniteSource__p4_settings',
			\ }
function! s:source.hooks.on_syntax(args, context) "{{{
	syntax match uniteSource__p4_settings_choose /<.*>/ containedin=uniteSource__p4_settings contained
	highlight default link uniteSource__p4_settings_choose Type 
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" �ݒ肷�鍀��
	if len(a:args) > 0
		let kind = a:args[0]
	else
		let kind = 'common'
	endif

	return map( keys(g:pf_setting), "{
				\ 'word' : <SID>get_word_from_pf_setting(v:val, 'common'),
				\ 'kind' : <SID>get_kind_from_pf_setting(g:pf_setting[v:val].common),
				\ 'action__valname' : v:val,
				\ 'action__kind' : kind,
				\ }")

endfunction "}}}

" ********************************************************************************
" source - source_p4_settings
" ********************************************************************************
let s:source_p4_settings = s:source
unlet s:source 

let s:source = {
			\ 'name' : 'p4_select',
			\ 'description' : '�����I��',
			\ 'hooks' : {},
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" �ݒ肷�鍀��
	if len(a:args) > 0
		let name = a:args[0].name
		let kind = a:args[0].kind
	endif

	" �������擾����
	let words = g:pf_setting[name][kind][1:]

	let val = 1
	let rtns = []

	for word in words 
		let rtns += [{
					\ 'word' : val.' - '.word,
					\ 'kind' : 'k_p4_select',
					\ 'action__name' : name,
					\ 'action__kind' : kind,
					\ 'action__bitnum' : val,
					\ }]
		let val = val * 2
	endfor	

	return rtns

endfunction "}}}
let s:source_p4_select = s:source
unlet s:source 

" ********************************************************************************
" <TRUE> ,  FALSE 
" @param[in]	bool	true or false
" @retval       str		�������Ԃ��܂�
" ********************************************************************************
function! s:get_word_from_bool(bool) "{{{
	if a:bool
		let str = '<TRUE>  FALSE '
	else
		let str = ' TRUE  <FALSE>'
	endif
	return str
endfunction "}}}

" ********************************************************************************
" <c:\tmp> , c:\tmp , c:\tmp 
" @param[in]	strs	{ 1, 'c:\tmp', 'c:\tmp'
" @retval       str		�������Ԃ��܂�
" ********************************************************************************
function! s:get_word_from_strs(strs) "{{{
	let select = a:strs[0]
	let strs   = map(copy(a:strs[1:]), "' '.v:val.' '")

	" �I����Ԃ̕ύX
	
	let lnum = 0
	while(lnum+1 < len(a:strs))
		let flg = select % 2 

		" �t���O������΁A�I����Ԃɂ���
		if flg 
			let strs[lnum] = '<'.a:strs[lnum+1].'>'
		endif

		" while �p�ɍX�V
		let lnum += 1
		let select = select / 2

	endwhile

	return join(strs)
endfunction "}}}

" ********************************************************************************
" word �o��
" @param[in]	val			������
" @param[in]	kind		�ݒ肵�Ă���source
" @retval		word		unite word
" ********************************************************************************
function! s:get_word_from_pf_setting(val, kind) "{{{
	let val = g:pf_setting[a:val][a:kind]
	let type = type(val)

	if type == 0
		let str = <SID>get_word_from_bool(val)
	else
		let str = <SID>get_word_from_strs(val)
	endif
	return printf('%-50s - %s', g:pf_setting[a:val].description, str)
endfunction "}}}

" ********************************************************************************
" kind
" @param[in]	val			������
" retval		kind		unite kind
" ********************************************************************************
function! s:get_kind_from_pf_setting(val) "{{{
	let type = type(a:val)

	if type == 0
		let kind = 'k_p4_settings_bool'
	else
		let kind = 'k_p4_settings_strs'
	endif
	return kind
endfunction "}}}


