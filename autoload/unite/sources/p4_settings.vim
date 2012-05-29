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
	syntax match uniteSource__p4_settings_group /".*"/ containedin=uniteSource__p4_settings contained

	highlight default link uniteSource__p4_settings_choose Type 
	highlight default link uniteSource__p4_settings_group Underlined  

endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" 設定する項目
	if len(a:args) > 0
		let kind = a:args[0]
	else
		let kind = 'common'
	endif

	let orders = copy(perforce#get_pf_settings_orders())
	return map( orders, "{
				\ 'word' : <SID>get_word_from_pf_setting(v:val, kind),
				\ 'kind' : <SID>get_kind_from_pf_setting(perforce#get_pf_settings(v:val,kind).datas),
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

" --------------------------------------------------------------------------------
"  subroutine
" --------------------------------------------------------------------------------
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

	" 選択状態の変更
	"
	if select < 0
		let strs   = map(copy(a:strs[1:]), "'<'.v:val.'>'")
	else
		let strs   = map(copy(a:strs[1:]), "' '.v:val.' '")
		let lnum = 0
		while(lnum <= len(a:strs))
			let flg = select % 2 

			" フラグがあれば、選択状態にする
			if flg 
				let strs[lnum] = '<'.a:strs[lnum+1].'>'
			endif

			" while 用に更新
			let lnum += 1
			let select = select / 2

		endwhile
	endif

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
	if !exists('g:pf_settings[a:val][a:kind]')
		let kind = common
	else
		let kind = a:kind 
	endif

	let val = g:pf_settings[a:val][kind]

	if type(val) == 0
		let str = <SID>get_word_from_bool(val)
	else
		let str = <SID>get_word_from_strs(val)
	endif

	if <SID>is_group(val)
		let rtn = '"'.g:pf_settings[a:val].description.'"'
	else
		let rtn = printf(' %-50s (%-30s,%-10s) - %s', g:pf_settings[a:val].description, a:val, kind, str)
	endif

	return rtn
endfunction "}}}

" ********************************************************************************
" kindを調べる
" @param[in]	val			引数名
" retval		kind		unite kind
" ********************************************************************************
function! s:get_kind_from_pf_setting(val) "{{{
	let type = type(a:val)

	if type == 0
		if <SID>is_group(a:val)
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
" タイトルか調べる
" @retval	rtn		TRUE	タイトル
" @retval	rtn		FALSE	タイトルではない
" ********************************************************************************
function! s:is_group(val) "{{{
	if type(a:val) == 0 && a:val < 0 
		let rtn = 1
	else 
		let rtn = 0
	endif
	return rtn
endfunction "}}}

