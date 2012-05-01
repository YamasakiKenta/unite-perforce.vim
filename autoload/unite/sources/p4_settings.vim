function! unite#sources#p4_settings#define()
	return s:source
endfunction

let s:source = {
			\ 'name' : 'p4_settings',
			\ 'description' : 'unite-perforce.vim ÇÃê›íË',
			\ 'is_quit' : 0,
			\ }
function! s:source.gather_candidates(args, context) "{{{

	let rtns = []
	for type in keys(g:pf_setting)
		let rtns += map( keys(g:pf_setting[type]), "{
					\ 'word' : <SID>get_word_from_pf_setting(type, v:val),
					\ 'kind' : <SID>get_kind_from_pf_setting(g:pf_setting[type][v:val].value.common),
					\ 'action__valname' : v:val,
					\ }")
	endfor

	return rtns

endfunction "}}}

" ********************************************************************************
" word èoóÕ
" @param[in]	typestr		bool , str Ç»Ç«
" @param[in]	val			à¯êîñº
" @retval		word		unite word
" ********************************************************************************
function! s:get_word_from_pf_setting(typestr, val) "{{{
	let str = string(g:pf_setting[a:typestr][a:val].value.common)
	return printf('%-5s : %-30s : %-30s = %s', a:typestr, a:val, g:pf_setting[a:typestr][a:val].description, str)
endfunction "}}}

" ********************************************************************************
" kind
" @param[in]	val			à¯êîñº
" retval		kind		unite kind
" ********************************************************************************
function! s:get_kind_from_pf_setting(val) "{{{
	let type = type(a:val)

	if type == 0
		let kind = 'k_p4_settings_bool'
	elseif type == 1
		let kind = 'k_p4_settings_str'
	elseif type == 3
		let kind = 'k_p4_settings_strs'
	endif
	return kind
endfunction "}}}
