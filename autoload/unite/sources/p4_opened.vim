function! unite#sources#p4_opened#define()
	return s:source
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

	let outs = []
	if len(a:args)
		" 引数がある場合
		for arg in a:args
			let outs += perforce#pfcmds('opened','','-c '.arg)
		endfor
	else
		" 引数がない場合
		let outs += perforce#pfcmds('opened','')
	endif

	" 追加ファイルだと問題が発生する
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_depot',
				\ 'action__depot' : <SID>get_DepotPath_from_opened(v:val)
				\ }")

	return candidates
endfunction "}}}

"================================================================================
" sub routine
"================================================================================
function! s:get_DepotPath_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # リビジョン番号の削除
endfunction "}}}
