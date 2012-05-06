function! unite#sources#p4_settings#define()
	return [s:source_p4_select, s:source_p4_settings]
endfunction

" ********************************************************************************
" source - p4_settings
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_settings',
			\ 'description' : 'unite-perforce.vim の設定',
			\ 'is_quit' : 0,
			\ 'syntax' : 'uniteSource__p4_settings',
			\ 'hooks' : {},
			\ }
function! s:source.hooks.on_syntax(args, context) "{{{
	syntax match uniteSource__p4_settings_choose /<.*>/ containedin=uniteSource__p4_settings contained
	highlight default link uniteSource__p4_settings_choose Type 
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" 設定する項目
	if len(a:args) > 0
		let kind = a:args[0]
	else
		let kind = 'common'
	endif

	return map( keys(g:pf_settings), "{
				\ 'word' : <SID>get_word_from_pf_setting(v:val, kind),
				\ 'kind' : <SID>get_kind_from_pf_setting(g:pf_settings[v:val][kind]),
				\ 'action__valname' : v:val,
				\ 'action__kind' : kind,
				\ }")

endfunction "}}}

" ********************************************************************************
" source - p4_select
" ********************************************************************************
let s:source_p4_settings = s:source
unlet s:source 

let s:source = {
			\ 'name' : 'p4_select',
			\ 'description' : '複数選択',
			\ 'hooks' : {},
			\ }
function! s:source.gather_candidates(args, context) "{{{

	" 設定する項目
	if len(a:args) > 0
		let name = a:args[0].name
		let kind = a:args[0].kind
	endif

	" 引数を取得する
	let words = g:pf_settings[name][kind][1:]

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
" @retval       str		文字列を返します
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
" @retval       str		文字列を返します
" ********************************************************************************
function! s:get_word_from_strs(strs) "{{{
	let select = a:strs[0]
	let strs   = map(copy(a:strs[1:]), "' '.v:val.' '")

	" 選択状態の変更
	
	let lnum = 0
	while(lnum+1 < len(a:strs))
		let flg = select % 2 

		" フラグがあれば、選択状態にする
		if flg 
			let strs[lnum] = '<'.a:strs[lnum+1].'>'
		endif

		" while 用に更新
		let lnum += 1
		let select = select / 2

	endwhile

	return join(strs)
endfunction "}}}

" ********************************************************************************
" word 出力
" @param[in]	val			引数名
" @param[in]	kind		設定しているsource
" @retval		word		unite word
" ********************************************************************************
function! s:get_word_from_pf_setting(val, kind) "{{{

	" 未定義なら共通設定を代入する
	if exists('g:pf_settings[a:val][a:kind]') == 0
		let g:pf_settings[a:val][a:kind] = g:pf_settings[a:val].common
	endif

	let val = g:pf_settings[a:val][a:kind]
	let type = type(val)

	if type == 0
		let str = <SID>get_word_from_bool(val)
	else
		let str = <SID>get_word_from_strs(val)
	endif
	return printf('%-50s - %s', g:pf_settings[a:val].description, str)
endfunction "}}}

" ********************************************************************************
" kind
" @param[in]	val			引数名
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

