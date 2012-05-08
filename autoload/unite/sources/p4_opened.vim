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
			\ }
function! s:get_DepotPath_from_opened(str) "{{{
	return substitute(a:str,'#.*','','')   " # リビジョン番号の削除
endfunction "}}}
function! s:source.gather_candidates(args, context) "{{{

	" クライアント or 通常
	let cmds = len(a:args)
				\ ? map( a:args, "'opened -c '.v:val") 
				\ : ['opened']

	" depot名の取得
	let outs = []
	for cmd in cmds
		let outs += perforce#cmds(cmd)
	endfor

	" 追加ファイルだと問題が発生する
	let candidates = map( outs, "{
				\ 'word' : v:val,
				\ 'kind' : 'k_depot',
				\ 'action__depot' : <SID>get_DepotPath_from_opened(v:val)
				\ }")

	return candidates
endfunction "}}}
