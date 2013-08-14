let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#p4_opened#define()
	return s:source_p4_opened
endfunction


let s:source_p4_opened = {
			\ 'name'         : 'p4/opened',
			\ 'description'  : '編集しているファイルの表示 ( チェンジリスト番号 )',
			\ 'default_kind' : 'k_depot',
			\ 'is_quit'      : 0,
			\ }
function! s:source_p4_opened.gather_candidates(args, context) "{{{
	" ********************************************************************************
	" source - p4_opened 
	" @param[in]     a:args[] = NULL,
	"                           0,
	"                           {'chnum' : 1, 'client' : '-p localhost:1818' }:
	" ********************************************************************************
	" 引数の設定

	let data_ds = perforce#source#get_data_client('-c ', 'chnum', a:args)

	let tmps = []
	for data_d in data_ds
		let chnum            = data_d.chnum
		let use_port_clients = data_d.use_port_clients
		call extend(tmps, perforce#cmd#clients(use_port_clients, 'p4 opened '.chnum))
	endfor

	" 追加ファイルだと問題が発生する
	let candidates = []
	for tmp in tmps
		let client = tmp.client
		let tmps = map(tmp.outs, "{
					\ 'word'           : client.' : '.v:val,
					\ 'action__depot'  : perforce#get#depot#from_opened(v:val),
					\ 'action__client' : client,
					\ }")

		call extend(candidates , tmps)
	endfor

	return candidates
endfunction
"}}}

call unite#define_source(s:source_p4_opened) 

let &cpo = s:save_cpo
unlet s:save_cpo

