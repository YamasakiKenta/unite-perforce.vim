let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_filelog#define()
	return s:source
endfunction

let s:source = { 
			\ 'name' : 'p4_filelog',
			\ 'description' : '履歴',
			\ }
function! s:source.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" @par ファイルの履歴を表示する
	" @param[in]	arg		表示する履歴のdepot
	" @par
	" "... ... branch into //depot/branch_1/mind/Test/AAA BBB/AAA BBB.txt.txt#1
	" ********************************************************************************
	let candidates = []

	let tmps = perforce_2#get_data_client('', 'file_', a:args)

	for tmp in tmps 
		let file_  = tmp.file_
		let datas  = perforce#cmd#use_port_clients('p4 filelog '.perforce#get_kk(file_))
		for data in datas
			let candidates += map(filter(data.outs, "v:val =~ '\.\.\. #'"), "{ 
						\ 'word'           : v:val,
						\ 'kind'           : 'k_p4_filelog',
						\ 'action__out'    : v:val,
						\ 'action__cmd'    : 'filelog',
						\ 'action__path'   : file_,
						\ 'action__client' : data.client,
						\ }")
		endfor
	endfor
	
	return candidates
endfunction 
"}}}

call unite#define_source(s:source)

let &cpo = s:save_cpo
unlet s:save_cpo

