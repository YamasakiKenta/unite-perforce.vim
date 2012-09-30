let s:perforce_setting_unite_kind = {
			\ 'title' : 'k_null',
			\ 'bool' : 'k_p4_settings_bool',
			\ 'strs' : 'k_p4_settings_strs',
			\ }

function! unite#sources#p4_settings#define()
	return [s:source_p4_select, s:source_p4_settings]
endfunction

" ********************************************************************************
" source - p4_settings
" ********************************************************************************
let s:source = {
			\ 'name'        : 'p4_settings',
			\ 'description' : 'unite-perforce.vim �̐ݒ�',
			\ 'is_quit'     : 0,
			\ 'syntax'      : 'uniteSource__p4_settings',
			\ 'hooks'       : {},
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
				\ 'kind' : s:get_kind_from_pf_setting(v:val),
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
			\ 'name'        : 'p4_select',
			\ 'description' : '�����I��',
			\ 'hooks'       : {},
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" �ݒ肷�鍀��
	if len(a:args) > 0
		let type = a:args[0].type
		let kind = a:args[0].kind
	endif

	" �������擾����
	let words = perforce#data#get_orig(type,kind)[1:]

	let val = 1
	let num = 1
	let rtns = []

	for word in words 
		let rtns += [{
					\ 'word' : val.' - '.word,
					\ 'kind' : 'k_p4_select',
					\ 'action__type' : type,
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
	let val         = perforce#data#get_orig(a:type, a:kind)
	let kind        = perforce#data#get_kind(a:type, a:kind)
	let description = perforce#data#get(a:type, 'description')
	let type        = perforce#data#get(a:type, 'type')

	let end_flg = 0
	let str = 'ERROR'
	if type == 'bool'
		let str = s:get_word_from_bool(val)
	elseif type == 'strs'
		let str = s:get_word_from_strs(val)
	elseif type == 'title'
		let end_flg = 1
		let rtn = '"'.perforce#data#get(a:type, 'description').'"'
	endif

	if end_flg == 0
		let star = (kind=='common') ? '*' : ' '
		let rtn = printf(' %-30s %50s - %s', description, star."".a:type.''.star, str)
	endif

	return rtn
endfunction "}}}

function! s:get_kind_from_pf_setting(val) "{{{
	" ********************************************************************************
	" kind�𒲂ׂ�
	" @param[in]	val			������
	" retval		kind		unite kind
	" ********************************************************************************
	"
	let type = perforce#data#get(a:val, 'type')
	return s:perforce_setting_unite_kind[type]

endfunction "}}}

