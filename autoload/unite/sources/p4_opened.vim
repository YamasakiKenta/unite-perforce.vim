let s:save_cpo = &cpo
set cpo&vim

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
	if len(a:args) > 0
		let datas = map(a:args, "'-c '.v:val")
	else 
		let datas = [""]
	endif

	let tmps = []
	for arg in datas
		call extend(tmps, perforce#cmd#new('opened', '', arg))
	endfor

	" 追加ファイルだと問題が発生する
	let candidates = []
	for tmp in tmps

		let client = tmp.client
		let tmps = map(tmp.outs, "{
					\ 'word'           : ''.client.' : '.v:val,
					\ 'kind'           : 'k_depot',
					\ 'action__depot'  : perforce#get#depot#from_opened(v:val),
					\ 'action__client' : client,
					\ }")
		call extend(candidates , tmps)
	endfor


	return candidates
endfunction
"}}}
let s:source_p4_opened = deepcopy(s:source)

call unite#define_source(s:source_p4_opened) 

let &cpo = s:save_cpo
unlet s:save_cpo

