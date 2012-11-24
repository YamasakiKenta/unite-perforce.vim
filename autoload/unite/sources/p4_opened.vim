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

	" 引数の設定
	let tmps = []
	for arg in extend([''], map(a:args, "'-c '.v:val"))
		call extend(tmps, perforce#pfcmds_new('opened', '', arg))
	endfor

	" 追加ファイルだと問題が発生する
	let candidates = []
	for tmp in tmps

		let client = tmp.client
		let tmps = map(tmp.outs, "{
					\ 'word'           : ''.client.' : '.v:val,
					\ 'kind'           : 'k_depot',
					\ 'action__depot'  : perforce#get_depot_from_opened(v:val),
					\ 'action__client' : client,
					\ }")
		call extend(candidates , tmps)
	endfor


	return candidates
endfunction "}}}
let s:source_p4_opened = deepcopy(s:source)

call unite#define_source(s:source_p4_opened) 
