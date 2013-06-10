let s:save_cpo = &cpo
set cpo&vim


function! unite#sources#p4_filelog#define()
	return s:source
endfunction

function! s:revision_num(str) "{{{
	return matchstr(a:str, '#\zs\d*')
endfunction 
"}}}

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

	let data_ds = perforce_2#get_data_client('', 'file_', a:args)

	for data_d in data_ds 
		let file_            = data_d.file_
		let use_port_clients = data_d.use_port_clients

		let datas = perforce#cmd#use_port_clients('p4 filelog '.perforce#get_kk(file_))
		for data in datas
			let candidates += map(filter(data.outs, "v:val =~ '\.\.\. #'"), "{ 
						\ 'word'           : v:val,
						\ 'kind'           : 'k_p4_filelog',
						\ 'action__revnum' : s:revision_num(v:val),
						\ 'action__out'    : v:val,
						\ 'action__cmd'    : 'filelog',
						\ 'action__depot'  : file_,
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

