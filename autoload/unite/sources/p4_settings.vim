function! unite#sources#p4_settings#define()
	return [s:source_p4_select, s:source_p4_settings]
endfunction

" ********************************************************************************
" source - p4_settings
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_settings',
			\ 'description' : 'unite-perforce.vim �̐ݒ�',
			\ 'is_quit' : 0,
			\ 'syntax' : 'uniteSource__p4_settings',
			\ 'hooks' : {},
			\ }
function! s:source.hooks.on_syntax(args, context) "{{{
	syntax match uniteSource__p4_settings_choose /<.\{-}>/ containedin=uniteSource__p4_settings contained
	syntax match uniteSource__p4_settings_group /".*"/ containedin=uniteSource__p4_settings contained

	highlight default link uniteSource__p4_settings_choose Type 
	highlight default link uniteSource__p4_settings_group Underlined  

endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" �ݒ肷�鍀��
	if len(a:args) > 0
		let kind = a:args[0]
	else
		let kind = 'common'
	endif

	let orders = copy(perforce#data#get_orders())
	return map( orders, "{
				\ 'word' : s:get_word_from_pf_setting(v:val, kind),
				\ 'kind' : s:get_kind_from_pf_setting(perforce#data#get(v:val,kind)),
				\ 'action__valname' : v:val,
				\ 'action__kind' : kind,
				\ }")

endfunction "}}}
let s:source_p4_settings = s:source
unlet s:source 

" ********************************************************************************
" source - p4_select
" ********************************************************************************
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
	let words = perforce#data#get_orig(name,kind)[1:]

	let val = 1
	let num = 1
	let rtns = []

	for word in words 
		let rtns += [{
					\ 'word' : val.' - '.word,
					\ 'kind' : 'k_p4_select',
					\ 'action__name' : name,
					\ 'action__kind' : kind,
					\ 'action__bitnum' : val,
					\ 'action__num' : num,
					\ }]
		let val = val * 2
		let num = num + 1
	endfor	

	return rtns

endfunction "}}}
let s:source_p4_select = s:source
unlet s:source 

" --------------------------------------------------------------------------------
"  subroutine
" --------------------------------------------------------------------------------
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

	" �I����Ԃ̕ύX
	"
	"�S�I��
	if select < 0
		let strs   = map(copy(a:strs[1:]), "'<'.v:val.'>'")
	else
		let strs   = map(copy(a:strs[1:]), "' '.v:val.' '")
		let lnum = 0
		while(lnum <= len(a:strs))
			let flg = select % 2 

			" �t���O������΁A�I����Ԃɂ���
			if flg 
				if exists('strs[lnum]')
					let strs[lnum] = '<'.a:strs[lnum+1].'>'
				endif
			endif

			" while �p�ɍX�V
			let lnum += 1
			let select = select / 2

		endwhile
	endif

	return join(strs)
endfunction "}}}

function! s:get_word_from_pf_setting(type, kind) "{{{
" ********************************************************************************
" word �o��
" @param[in]	typeval			������
" @param[in]	kind		�ݒ肵�Ă���source
" @retval		word		unite word
" ********************************************************************************

	" ����`�Ȃ狤�ʐݒ��������
	let val  = perforce#data#get_orig(a:type, a:kind)
	let kind = perforce#data#get_kind(a:type, a:kind)

	if type(val) == 0
		let str = s:get_word_from_bool(val)
	else
		let str = s:get_word_from_strs(val)
	endif

	if s:is_group(val)
		let rtn = '"'.perforce#data#get(a:type, 'description').'"'
	else
		let rtn = printf(' %-50s (%-30s,%-10s) - %s', perforce#data#get(a:type, 'description'), a:type, kind, str)
	endif

	return rtn
endfunction "}}}

" ********************************************************************************
" kind�𒲂ׂ�
" @param[in]	val			������
" retval		kind		unite kind
" ********************************************************************************
function! s:get_kind_from_pf_setting(val) "{{{
	let type = type(a:val)

	if type == type(1)
		if s:is_group(a:val)
			let kind = 'k_null'
		else
			let kind = 'k_p4_settings_bool'
		endif
	else
		let kind = 'k_p4_settings_strs'
	endif
	return kind
endfunction "}}}

" ********************************************************************************
" �^�C�g�������ׂ�
" @retval	rtn		TRUE	�^�C�g��
" @retval	rtn		FALSE	�^�C�g���ł͂Ȃ�
" ********************************************************************************
function! s:is_group(val) "{{{
	if type(a:val) == 0 && a:val < 0 
		let rtn = 1
	else 
		let rtn = 0
	endif
	return rtn
endfunction "}}}

