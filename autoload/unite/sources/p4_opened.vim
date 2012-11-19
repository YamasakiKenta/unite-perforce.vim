function! unite#sources#p4_opened#define()
	return s:source_p4_opened
endfunction

" ********************************************************************************
" source - p4_opened 
" @param[in]	args		表示するチェンジリスト
" ********************************************************************************
let s:source = {
			\ 'name' : 'p4_opened',
			\ 'description' : '編集しているファイルの表示 ( チェンジリスト番号 )',
			\ 'is_quit' : 0,
			\ }
function! s:source.gather_candidates(args, context) "{{{

	if len(a:args)
		" 引数がある場合
		let tmps = map( a:args, "
					\ perforce#pfcmds_new('opened','','-c '.v:val)
					\ ")
	else
		" 引数がない場合
		let tmps = perforce#pfcmds_new('opened','','')
	endif

	" 追加ファイルだと問題が発生する
	let candidates = []
	for tmp in tmps
		let client = tmp.client
		call extend(candidates , map(tmp.outs, "{
					\ 'word'           : ''.client.' : '.v:val,
					\ 'kind'           : 'k_depot',
					\ 'action__depot'  : perforce#get_depot_from_opened(v:val),
					\ 'action__client' : client,
					\ }"))
	endfor

	return candidates
endfunction "}}}
let s:source_p4_opened = deepcopy(s:source)

"call unite#define_source(s:source_p4_opened) | unlet s:source_p4_opened
