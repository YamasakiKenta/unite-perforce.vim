if 0
function! unite#sources#p4_opened#define()
	return s:source_p4_opened
endfunction
endif

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

	let tmps = []
	if len(a:args)
		" 引数がある場合
		for arg in a:args
			let tmps += perforce#pfcmds_with_client_from_data('opened','','-c '.arg,'')
		endfor
	else
		" 引数がない場合
		let tmps += perforce#pfcmds_with_client_from_data('opened','','')
	endif

	" 追加ファイルだと問題が発生する
	let candidates = []
	for tmp in tmps
		let port = tmp.port
		let client = tmp.client
		let candidates = map( tmp.outs, "{
					\ 'word'           : ''.port.' - '.client.' : '.v:val,
					\ 'kind'           : 'k_depot',
					\ 'action__depot'  : perforce#get_depot_from_opened(v:val),
					\ 'action__port'   : port,
					\ 'action__client' : client,
					\ }")
	endfor

	return candidates
endfunction "}}}
let s:source_p4_opened = deepcopy(s:source)
call unite#define_source(s:source_p4_opened) | unlet s:source_p4_opened
